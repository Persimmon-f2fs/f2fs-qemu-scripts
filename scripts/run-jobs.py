#!/usr/bin/python3

import argparse
import json
import yaml
import multiprocessing as mp
import asyncio
import subprocess as sp
import signal
import sys

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# define the argument parser
parser = argparse.ArgumentParser(description='Run workloads concurrently')
parser.add_argument('--file', help='configuration file', nargs=1, required=True)

def cmd(command):
    return asyncio.create_subprocess_shell(
        command,
        stdout=asyncio.subprocess.PIPE,
    )

async def runJob(name, prereqs, command):
    for prereq in prereqs:
        prereqProc = await cmd(prereq)
        await prereqProc.communicate()
        if prereqProc.returncode != 0:
            eprint(f'failed: {prereq}')
            return {
                "name": name,
                "returncode": prereqProc.returncode,
                "output": None
            }

    commandProc = await cmd(command)
    result, _ = await commandProc.communicate()

    resultJson = None
    try:
        resultJson = json.loads(result.decode('utf-8'))
    except Exception as e:
        # failed to parse, silently fail
        eprint(e)

    return {
        "name": name,
        "returncode": commandProc.returncode,
        "output": resultJson if resultJson else result.decode('utf-8')
    }

async def main(fileArg: list):
    config = None
    [file] = fileArg

    with open(file, 'r') as fp:
        config = yaml.safe_load(fp)

    eprint(f'=====> Running {len(config["jobs"])} jobs')

    allJobs = config["jobs"]
    numParallel = config \
        .get("config", {}) \
        .get("numParallel", None) or allJobs

    output = []
    
    while allJobs:
        run = []
        while allJobs:
            job = allJobs.pop(0) 
            run.append(job)
            if len(run) == numParallel:
                break
        runOutput = await asyncio.gather(
            *[runJob(**job) for job in run]
        )
        output.extend(runOutput)

    print(json.dumps(output))

if __name__ == "__main__":
    args = parser.parse_args()
    asyncio.run(main(args.file))


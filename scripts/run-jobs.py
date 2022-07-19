#!/usr/bin/python3

import argparse
import json
import yaml
import multiprocessing as mp
import asyncio
import subprocess as sp
import signal

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
            return {
                "name": name,
                "returncode": prereqProc.returncode,
                "output": None
            }

    commandProc = await cmd(command)
    result, _ = await commandProc.communicate()

    resultJson = None
    try:
        resultJson = json.parse(result.decode('utf-8'))
    except:
        # failed to parse, silently fail
        eprint("failed to parse!")
        pass

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

    print(f'=====> Running {len(config["jobs"])} jobs')

    print(config)

    output = await asyncio.gather(
        *[runJob(**job) for job in config["jobs"]]                    
    ) 

    print(json.dumps(output))

if __name__ == "__main__":
    args = parser.parse_args()
    asyncio.run(main(args.file))


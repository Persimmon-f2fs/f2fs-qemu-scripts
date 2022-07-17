#!/usr/bin/python

import argparse
import json
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
    ):
    

async def runJob(name, testDir, device, fioFile, fioArgs):
    await cmd(f'mkdir {testDir}').communicate()
    blkzoneProc = cmd(
            f'perl /share/poll_blkzone.perl {device}'
    )
    meminfoProc = cmd(
            f'perl /share/poll_meminfo.perl'
    )

    beforeSmartStdout = await cmd(f'smartctl -aj {device}') \
            .communicate()

    fioStdout, = await cmd(f'fio --directory {testDir} {fioArgs} {fioFile}').communicate()

    afterSmartStdout = await cmd(f'smartctl -aj {device}') \
            .communicate()

    # send signals to the polls
    blkzoneProc.signal(signal.SIGTERM)
    meminfoProc.signal(signal.SIGTERM)

    blkzoneStdout = await blkzoneProc.communicate()
    meminfoStdout = await meminfoProc.communicate()

    return {
        blkzoneOutput: blkzoneStdout,
        meminfoOutput: meminfoStdout,
        beforeSmartOutput: json.parse(beforeSmartStdout),
        afterSmartOutput: json.parse(afterSmartStdout),
    }

async def main(fileArg: list):
    config = None
    [file] = fileArg
    allowedFields = {'name', 'testDir', 'device', 'fioFile', 'fioArgs'}

    with open(file, 'r') as fp:
        config = json.load(fp)

    # validate the file
    if not isinstance(config, list):
        raise Exception("json file must be a list")
    for job in config:
        if not all(x in allowedFields for x in job.keys()):
            raise Exception("each object must only have name, testDir, and device attrs")
        
    output = await asyncio.gather(
        *[runJob(**job) for job in config]                    
    ) 

    print(output)

if __name__ == "__main__":
    args = parser.parse_args()
    try: 
        asyncio.run(main(args.file))
    except BaseException as e:
        print(e)


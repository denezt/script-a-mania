#!/usr/bin/env python3

from datetime import datetime
import json
import os

def resultsCreate(jsonfile):
    timestamp = datetime.now().strftime("%d%m%Y%H%M%S")
    for file_list in jsonfile:
        if os.path.exists("{}.json".format(file_list)):
            jsonfp = open("{}.json".format(file_list),"r")
            csvfp = open("{}-{}-status.csv".format(file_list, timestamp), "a")
            translation = json.loads(jsonfp.read())
            csv_header = "id;key;value;status;\n"
            print(csv_header)
            csvfp.writelines(csv_header)
            incr = 0
            for k, v in translation.items():
                incr += 1
                print("{};{};{};Correct;".format(incr,k,v))
                csvfp.writelines("{};{};{};Correct;\n".format(incr,k,v))
            # Close Files
            jsonfp.close()
            csvfp.close()
        else:
            print("Unable to find file {}.json".format(file_list))
    return 0

if __name__ == '__main__':
    resultsCreate(jsonfile=[ "translation-gb", "translation-en"])    

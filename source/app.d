import std.file;
import std.stdio;
import std.string;
import core.stdc.stdlib;
import ysfs;
import util;

const string appHelp = "
Usage: ysfs [file] [operation] {args}

operations:
	make                    : creates a YSFS file system
	setDiskName {disk_name} : sets the disk name (max 16 characters)
	showInfo                : shows YSFS disk info
	addFile {source} {dest} : creates a file in the file system at {dest} copied from the file {source} in your file system
	listFiles               : shows all files in the YSFS file system 
";

void main(string[] args) {
	if (args.length < 3) {
		writeln(appHelp.strip());
	    return; // TODO: show usage
	}

	string  fsFile = args[1];
	ubyte[] fsData;

	if (fsFile.exists()) {
	    fsData = cast(ubyte[]) std.file.read(fsFile);
	}

	switch (args[2]) {
	    case "make": {
	        std.file.write(fsFile, YSFS_CreateFileSystem());
	        break;
	    }
	    case "setDiskName": {
            if (args.length != 4) {
                return; // TODO: show usage
            }

	        YSFS_SetDiskName(fsData, args[3]);
	        std.file.write(fsFile, fsData);
	        break;
	    }
	    case "showInfo": {
	    	YSFS_ShowInfo(fsData);
	    	break;
	    }
	    case "addFile": {
	    	if (args.length != 5) {
	    		stderr.writefln("Usage: ysfs addFile (source) (dest path)");
	    		return;
	    	}

	    	YSFS_AddFileAt(fsData, args[3], args[4]);
	    	std.file.write(fsFile, fsData);
	    	break;
	    }
	    case "listFiles": {
	    	YSFS_ListFiles(fsData);
	    	break;
	    }
	    default: {
	        stderr.writefln("Unknown operation %s", args[2]);
	        exit(1);
	    }
	}
}

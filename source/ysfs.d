import std.file;
import std.stdio;
import std.string;
import std.bitmanip;
import core.stdc.stdlib;
import util;

enum YSFS_FileType {
	File      = 0,
	Directory = 1,
	Link      = 2
}

ubyte[] YSFS_CreateFileSystem() {
    ubyte[] fs;

    for (size_t i = 0; i < 8; ++i) {
        fs ~= 0;
    }

    fs ~= 'Y';
    fs ~= 'S';
    fs ~= 'F';
    fs ~= 'S';

    string defaultDiskName = "UNTITLED";
    fs ~= Pad!ubyte(cast(ubyte[]) defaultDiskName, 16, 0);

    fs = Pad(fs, 512, 0);

    assert(fs.length == 512);

    return fs;
}

void YSFS_SetDiskName(ref ubyte[] fs, string newName) {
    ubyte[] name = cast(ubyte[]) newName;

    if (name.length > 16) {
        stderr.writefln("Error: name '%s' too big", newName);
        exit(1);
    }

    name = Pad(name, 16, 0);

    assert(name.length == 16);

    fs[0x000C .. 0x001C] = name;
}

void YSFS_ShowInfo(ref ubyte[] fs) {
	if (cast(string) (fs[0x0008 .. 0x000C]) != "YSFS") {
		stderr.writeln("Not a YSFS file system");
		exit(1);
	}

	writefln("Disk name: %s", cast(string) fs[0x000C .. 0x001C]);
}

ubyte[] YSFS_CreateFileSector(string path, ushort fragmentNumber, ubyte[] contents) {
	ubyte[] sector;

	sector ~= 'Y';
	sector ~= 'S';
	sector ~= 'F';
	sector ~= 'S';

	ubyte[] rawPath;
	rawPath ~= cast(ubyte[]) path;
	rawPath  = Pad(rawPath, 128, 0);

	sector ~= rawPath;

	sector ~= cast(ubyte) YSFS_FileType.File;

	ubyte[2] fragmentNumberBytes = nativeToLittleEndian(fragmentNumber);

	sector ~= fragmentNumberBytes[0];
	sector ~= fragmentNumberBytes[1];

	for (size_t i = 0; i < (4 * 3); ++i) {
		// Time of creation
		// Time of last read/write
		// Time of last write
		sector ~= 0;
	}

	for (size_t i = 0; i < 5; ++i) { // Unused
		sector ~= 0;
	}

	for (size_t i = 0; i < 360; ++i) { // Contents
		sector ~= contents[i];
	}

	if (sector.length != 512) {
		stderr.writefln("Wrong sector length, need 512, got %d", sector.length);
		exit(1);
		// assert(sector.length == 512);
	}

	return sector;
}

void YSFS_AddFileAt(ref ubyte[] fs, string from, string to) {
	ubyte[] contents = cast(ubyte[]) std.file.read(from);

	writefln("Adding file of size %d", contents.length);

	ubyte[][] fragmentedContents = SplitChunks(contents, 360, 0);

	foreach (i, ref fragment ; fragmentedContents) {
		assert(fragment.length == 360);
		fs ~= YSFS_CreateFileSector(to, cast(ushort) i, fragment);
	}
}

struct YSFS_FileEntry {
	YSFS_FileType type;
	string        path;
	size_t        fragments;
}

void YSFS_ListFiles(ubyte[] fs) {
	fs = fs[512 .. $];

	ubyte[][] sectors = [[]];
	size_t    sectorSize;

	for (size_t i = 0; i < fs.length; ++i) {
		sectors[$ - 1] ~= fs[i];

		++ sectorSize;

		if (sectorSize == 512) {
			sectorSize  = 0;
			sectors    ~= [];
		}
	}

	YSFS_FileEntry[string] files;

	foreach (i, ref sector ; sectors) {
		string        path = (cast(string) sector[0x0004 .. 0x0084]).fromStringz();
		YSFS_FileType type = cast(YSFS_FileType) sector[0x0084];
		
		ubyte[2]      fragmentNumBytes = sector[0x0085 .. 0x0087];
		ushort        fragmentNum      = littleEndianToNative!(ushort)(fragmentNumBytes);

		if (path in files) {
			++ files[path].fragments;
		}
		else {
			files[path] = YSFS_FileEntry(type, path, 1);
		}
	}

	foreach (key, value ; files) {
		writefln("%s: %s (%d fragments)", value.type, value.path, value.fragments);
	}
}

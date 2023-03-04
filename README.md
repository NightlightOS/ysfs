# ysfs

## disk info specs (first sector)

| Attribute name          | Size (bytes) | Offset in sector | Purpose                                                 |
| ----------------------- | ------------ | ---------------- | ------------------------------------------------------- |
| Magic bytes             | 4            | 0x0008           | To show the disk is formatted with YSFS (YSFS in ASCII) |
| Disk name               | 16           | 0x000C           | Name of the disk                                        |

Some bytes are left at the beginning in case you need to add machine code for jumping past the YSFS disk attribute data

## file data specs

| Attribute name          | Size (bytes) | Offset in sector | Purpose                                     |
| ----------------------- | ------------ | ---------------- | ------------------------------------------- |
| Magic bytes             | 4            | 0x0000           | Same as disk info magic bytes
| Path                    | 128          | 0x0004           | File name/file path                         |
| File type               | 1            | 0x0084           | Enumeration for type of file                |
| Fragment number         | 2            | 0x0085           | Index of array of fragments                 |
| Time of creation        | 4            | 0x0087           | Time the file was created                   |
| Time of last read/write | 4            | 0x008B           | Time the file was last read from/written to |
| Time of last write      | 4            | 0x008F           | Time the file was last written to           |
| Unused                  | 5            | 0x0093           | Unused                                      |
| File contents           | 360          | 0x0097           | Contents of the file (depends on file type) |

### file contents and file type

#### File (0)
All 360 bytes are the contents of the file

#### Directory (1)
Contents are ignored

#### Link (2)
First 128 bytes of the contents are a path, the rest is ignored

### Other info
multi-byte integers are stored as little endian

times are stored as seconds since january 1st, 2023 in an unsigned 32-bit integer

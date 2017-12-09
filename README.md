# Zombihunter
Collection of perl scripts to organize huge sets of folders and files.

[[ Background ]]
At work we use a shared drive which has appr. 1,5 TB of data which accumulated there over the last decade.
Lots of people joined the company and moved on again.
But their (valuable) data do still exist on this drive.
Some new people work or have worked with this data and have copied them over to their own folder structures.
Thus we ended up with a lot of redundant and partly abandoned data.

Since we have to pay for each MB, inspired by existing software and the fun of programming with perl I created this 'project' to optimize and maintain our drive.

We are working within a Microsoft environment thus this software focusses on this OS but might rund on other systems too.

[[ Functionality ]]
The functions I plan to implement are as follows:
1)  Index all available files and directories in and below a given starting directory.
2)  Retrieve some data about the files and directories like:
        a)  file name
        b)  path to the file
        c)  size of the file
        d)  extension of the file
        e)  MD5 checksum of the file
        f)  date of last modification
3)  Identify doublettes and rank the propability that they are identical by
        a)  MD5 checksum of the file
        b)  MD5 checksum of file + name + size + date
    Maybe make the identity criteria configurable.
4)  Handle doublettes by copying one of them to a common directory and either
        a)  replace the file in the folder by a text file mentioning the new
            storage location
        b)  replace the file in the folder by a Windows shortcut
        c)  allow the user to define the propability level for the to be copied/
            deleted files (only name, name + file size, name + file size + MD5)

[[ Considerations ]]

*   Use log-file to recover original situation before moving files an generating
    shortcuts. Structure of the log-file:
        *   <path and name source file>|
            <path and name of file in common folder>|
            <path and name of shortcut>
*   Add a mode which simulates a optimization run which just generates logs
*   Add a file to each original file in the common folder which contains
    information about its usage
*   Allow update of the common folder in case the to be optimized folder
    structure has grown again or changed significantly
        *   add common files to the common folder
        *   remove files from the common folder in case all shortcuts linked to
            it have been removed
*   Store program settings in config file; maybe allow several configs
*   Use Win32::Packer for deployment
*   Calculate how much the storage will be optimized
*   Config option: exclude dedicated file extensions
*   Config option: exclude dedicated folders/paths e.g.
        *   C:\
        *   C:\Windows
*   Due to the size and the number of files/folders of the drive it might be
    necessary to use Directory::Scanner

[[ Be warned ]]

If you read my code you'll immediatly find out that I'm not a software architect ;-)
I do this programming for fun and want to achieve a certain functionality not because of the beauty of code.
Nevertheless your feedback for improvements would be warmly welcome and highly appreciated.

(c) LiK 2017-12

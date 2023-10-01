# System View Description

Code in this directory are generated from CMSIS-SVD files by svd2ada utility.

This code is intended to be used by Hardware Proxy Layer only.

To regenerate code use

   svd2ada ATSAM3X8E.svd --output=generated --package="BBF.HRI" --boolean

and copy necessary packages from the generated directory.

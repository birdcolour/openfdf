function img = fdf3d(path)
% m-file that can open 3D Varian FDF imaging files in MATLAB.
% Usage: img = fdf;
% Your 3D image data will be loaded into img
%
% Shanrong Zhang
% Department of Radiology
% University of Washington
% 
% email: zhangs@u.washington.edu
% Date: 12/19/2004
% 
% Fix Issue so it is able to open both old Unix-based and new Linux-based FDF
% Date: 11/22/2007

warning off MATLAB:divideByZero;

[fid] = fopen(path,'r');

num = 0;
done = false;
machineformat = 'ieee-be'; % Old Unix-based  
line = fgetl(fid);

while (~isempty(line) && ~done)
    line = fgetl(fid);
    
    if strmatch('int    bigendian', line)
        machineformat = 'ieee-le'; % New Linux-based    
    end
    
    if strmatch('float  matrix[] = ', line)
        [token, rem] = strtok(line,'float  matrix[] = { , , };');
        M(1) = str2num(token);
        [token, rem] = strtok(rem, ', , };');
        M(2) = str2num(token);
        M(3) = str2num(strtok(rem,', };'));
    end
    if strmatch('float  bits = ', line)
        [token, rem] = strtok(line,'float  bits = { , };');
        bits = str2num(token);
    end

    num = num + 1;
    
    if num > 41
        done = true;
    end
end

skip = fseek(fid, -M(1) * M(2) * M(3)*bits/8, 'eof');

img = fread(fid, M(1) * M(2) * M(3), 'float32', machineformat);
img = reshape(img, [M(1), M(2), M(3)]);
img = img';

fclose(fid);

end

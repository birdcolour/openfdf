function img = fdf2d(path)
% m-file that can open 2D Varian FDF imaging files in MATLAB.
% Usage: img = fdf;
% Your 2D image data will be loaded into img
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
        [token, rem] = strtok(line,'float  matrix[] = { , };');
        M(1) = str2num(token);
        M(2) = str2num(strtok(rem,', };'));
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

skip = fseek(fid, -M(1)*M(2)*bits/8, 'eof');

img = fread(fid, M(1)* M(2), 'float32', machineformat);
img = reshape(img, [M(1), M(2)]);
img = img';

fclose(fid);

end
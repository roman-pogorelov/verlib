close all;
clear;

%% ����������� �����������
WIDTH = 16;

% ������������ ������� �������
i = 0 : 2^(WIDTH - 2) - 1;
sinTable = round(sin(i/(2^(WIDTH - 2)) * pi / 2) * (2^(WIDTH - 1) - 1));

%% ���������� �������� � ����
fid = fopen ('sin-lut.bin', 'w');
fwrite(fid, sinTable, 'uint16');
fclose(fid);

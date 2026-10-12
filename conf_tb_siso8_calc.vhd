
configuration conf_tb_siso8_copy of tb_siso8 is
  for structure
    for duv: siso8 use entity work.siso8(calc);
    end for;
    for tvc: tvc_siso8 use entity work.tvc_siso8(behavior);
    end for;
  end for;
end conf_tb_siso8_copy;

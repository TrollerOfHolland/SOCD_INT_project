
configuration conf_tb_siso8_rpn of tb_siso8 is
  for structure
    for duv: siso8 use entity work.siso8(rpn);
    end for;
    for tvc: tvc_siso_gen use entity work.tvc_siso_gen(tvc_siso_gen_arch);
    end for;
  end for;
end conf_tb_siso8_rpn;

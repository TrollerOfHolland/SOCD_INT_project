
configuration conf_tb_siso_gen_rpn of tb_siso_gen_top is
  for top 
    for tg: tb_siso_gen use entity work.tb_siso_gen(structure)
            generic map (word_length => 8);
      for structure
        for duv: siso_gen use entity work.siso_gen(rpn);
        end for;
        for tvc: tvc_siso_gen use entity work.tvc_siso_gen(tvc_siso_gen_arch);
        end for;
      end for;
    end for;
  end for;
end conf_tb_siso_gen_rpn;

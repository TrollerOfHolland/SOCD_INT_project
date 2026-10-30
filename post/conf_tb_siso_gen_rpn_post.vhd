-- Author: Lars Gortemaker (EDITED FOR POST_SYNTH SIMULATION)

configuration conf_tb_siso_gen_rpn_post of tb_siso_gen_top is
  for top 
    for tg: tb_siso_gen use entity work.tb_siso_gen(structure)
            generic map (DATA_WIDTH => 8);
      for structure
        for duv: siso_gen use entity work.siso_gen(flat_rpn_none_20);
        end for;
        for tvc: tvc_siso_gen use entity work.tvc_siso_gen(tvc_siso_gen_arch);
        end for;
      end for;
    end for;
  end for;
end conf_tb_siso_gen_rpn_post;

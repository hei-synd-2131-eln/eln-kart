new_project \
    -name {Kart_Board} \
    -location {C:\dev\eln_kart_sodimm200\Kart\Board\libero\ElnKart_SODIMM200_PMOD_tester\designer\impl1\Kart_Board_fp} \
    -mode {single}
set_programming_file -file {C:\dev\eln_kart_sodimm200\Kart\Board\libero\ElnKart_SODIMM200_PMOD_tester\designer\impl1\Kart_Board.pdb}
set_programming_action -action {PROGRAM}
run_selected_actions
save_project
close_project

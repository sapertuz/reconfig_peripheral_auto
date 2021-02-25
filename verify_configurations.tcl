set alldcp [glob $impl_dir/Config_*/top_route_design.dcp]
set idx [lsearch $alldcp "$impl_dir/Config_blank/top_route_design.dcp"]
set alldcp [lreplace $alldcp $idx $idx]
pr_verify -initial $impl_dir/Config_blank/top_route_design.dcp -additional $alldcp

close_project

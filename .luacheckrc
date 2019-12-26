local app = {
	globals = {
		"S", "C",
		"jprof", "PROF_REALTIME", "PROF_CAPTURE",
	}
}

stds.app = app
std   = "luajit+love+app"

ignore={"431", "212", "21/._*"}

exclude_files = {"rocks"}

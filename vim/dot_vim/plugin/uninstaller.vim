" Author:  Yury Altukhou 
" Date:    2004/12/22
" Email:   wind-xp@tut.by
" Version: 1.0

function! Uninstall (scriptName) "{{{1
	let script =expand(a:scriptName)
	let vimfiles=fnamemodify(script,":p:h:h").'/'
	let pluginname=fnamemodify(script,":t:r")
	let fileList=vimfiles."/etc/".pluginname
	exe "sp ".fileList
	exe 'global /^/:call delete("'.vimfiles.'".getline("."))'
	q
endfunction "}}}1

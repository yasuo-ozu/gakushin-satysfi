.PHONY:	open
open:
	$(MAKE) dc.pdf
	evince dc.pdf &

dc.pdf:	dc.saty patches
	eval `opam env` && satysfi dc.saty &> dc.out || cat dc.out | (tail -n 10 1>&2 && false)
	rm dc.out

dc.d:	dc.saty
	eval `opam env` && SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos util deps-make dc.saty > $@

-include: dc.d

patches:
	mkdir -p patches
	curl 'http://osksn2.hep.sci.osaka-u.ac.jp/~taku/kakenhiLaTeX/2021_spring/dc_utf_single_20210216.zip' -o patches/dc_utf_single.zip
	[ `md5sum patches/dc_utf_single.zip | cut -b -32` = 6e12df8c3a4d179fc7ad9e4f1ff286e5 ]
	cd patches && unzip -o dc_utf_single.zip

	cd patches ; seq 1 5 | while read NUM; do \
		echo '\documentclass{standalone}' > dc_header_0$${NUM}.tex && \
		echo '\usepackage[dvipdfmx]{graphicx}' >> dc_header_0$${NUM}.tex && \
		echo '\begin{document}' >> dc_header_0$${NUM}.tex && \
		echo '\includegraphics{dc_utf_single/subject_headers/dc_header_0'$${NUM}'.pdf}' >> dc_header_0$${NUM}.tex && \
		echo '\end{document}' >> dc_header_0$${NUM}.tex && \
		platex dc_header_0$${NUM}.tex && \
		dvipdfmx dc_header_0$${NUM} ; \
	done
	rm -rf patches/dc_utf_single.zip patches/dc_utf_single patches/*.{aux,tex,dvi,log}

.PHONY: clean
clean:
	rm -rf dc.{d,satysfi-aux} patches

.PHONY: distclean
distclean:
	@$(MAKE) clean
	rm -rf dc.pdf

-include: include.mk

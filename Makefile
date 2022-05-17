.PHONY:	open
open:
	$(MAKE) dc.pdf
	evince dc.pdf &

-include include.mk

dc.pdf:	dc.saty
	eval `opam env` && satysfi dc.saty | tee dc.out || cat dc.out | (tail -n 10 1>&2 && false)
	rm dc.out
	mv dc.pdf dc_bak.pdf
	gs -sOutputFile=dc.pdf -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibiltyLevel=1.4 -dNOPAUSE -dBATCH dc_bak.pdf
	rm dc_bak.pdf

%.d:	%.saty
	@eval `opam env` && SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos util deps-make "$<" --target "" --satysfi-version 0.0.5 2>/dev/null | tr ' :' '\n' | sed -e '/^$$/d' | while read LINE; do \
		cat "$$LINE" | sed -e 's/\(^\|[^\\]\)%.*$$/\1/' | sed -ne '/`/p' | sed -e 's/^.*`\([^`]*\)`.*$$/\1/' | sed -ne '/[a-zA-Z0-9]\+\.\(pdf\|jpg\)$$/p' | sed -e '/^http/d' | xargs -I{} echo '$(patsubst %.d,%.pdf,$@):	'`dirname "$$LINE"`'/{}' ; \
	done > "$@"


-include $(patsubst %.saty,%.d,$(wildcard *.saty))

.PHONY: clean
clean:
	rm -rf dc.{d,satysfi-aux}

.PHONY: distclean
distclean:
	@$(MAKE) clean
	rm -rf dc.pdf


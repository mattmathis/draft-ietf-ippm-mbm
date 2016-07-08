NAME=draft-ietf-ippm-model-based-metrics
TARGETS=$(NAME).txt $(NAME).html
TARGETS=$(NAME).html $(NAME).txt
WEBNAME=draft-ietf-ippm-model-based-metrics
# Make file below a link to the most recent published version
PRIOR=prior
WEBDIR=${HOME}/Downloads
WEBDIR=${HOME}/www/drafts
FORMATTED=`date`
LIB='XML_LIBRARY='${PWD}

top: all

recompile: $(TARGETS)

all: trigger $(TARGETS)  

trigger $(NAME).trig:
	touch $(NAME).trig

clean:
	rm -f $(NAME).trig $(NAME).tmp $(NAME).xml $(NAME).txt $(NAME).html $(NAME).txt.bar

# TODO: Properly depend on all source files: src/*.xml
.PHONY: $(NAME).xml
$(NAME).xml: $(NAME).trig
	tools/merge.py main.xml | sed  -e "s/FORMATTED/$(FORMATTED)/g" -e '/<\/rfc>/q' -e '/%/a\\ ' > $(NAME).tmp
	mv $(NAME).tmp $(NAME).xml

$(NAME).txt: $(NAME).xml
	-echo Making $(NAME).txt ======
	export $(LIB); xml2rfc --text $(NAME).xml

$(NAME).html: $(NAME).xml
	-echo Making $(NAME).html and $(NAME).color.html ======
	export $(LIB); xml2rfc --html $(NAME).xml

# Nonstandard rules to help the lazy^H^H^H busy

stage: $(NAME).txt $(NAME).html
	cp $(NAME).txt ${WEBDIR}/${WEBNAME}.txt
	cp $(NAME).xml ${WEBDIR}/${WEBNAME}.xml
	cp $(NAME).html ${WEBDIR}/${WEBNAME}.html
	chmod 644 ${WEBDIR}/${WEBNAME}*

# link prior.txt to Pub/whatever 
rfcdiff: $(NAME).txt
	tools/rfcdiff $(PRIOR).txt $(NAME).txt
	@echo See $(NAME)-from-$(PRIOR).diff.html

changebar: $(NAME).txt
	changebar $(NAME).txt prior.txt

spell: $(NAME).txt
	cat $(NAME).txt | aspell list | sort -u > spell.txt

less: trigger $(NAME).txt changebar
	less $(NAME).txt.bar

checkxml:
	for f in src/*.xml; do tidy -e -q -xml $$f ; done

colorize: $(NAME).html
	./tools/decorate.py global $(NAME).html > color_global.html
	./tools/decorate.py traffic $(NAME).html > color_traffic.html
	./tools/decorate.py model $(NAME).html > color_model.html

checks: colorize spell rfcdiff




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

stage: $(NAME).txt $(NAME).html
	cp $(NAME).txt ${WEBDIR}/${WEBNAME}.txt
	cp $(NAME).xml ${WEBDIR}/${WEBNAME}.xml
	cp $(NAME).html ${WEBDIR}/${WEBNAME}.html
	chmod 644 ${WEBDIR}/${WEBNAME}*

all: trigger $(TARGETS)  

trigger $(NAME).trig:
	touch $(NAME).trig

clean:
	rm -f $(NAME).trig $(NAME).tmp $(NAME).xml $(NAME).txt $(NAME).html $(NAME).txt.bar

# link prior.txt to Pub/whatever 
rfcdiff: $(NAME).txt
	tools/rfcdiff $(PRIOR).txt $(NAME).txt
	@echo See $(NAME)-from-$(PRIOR).diff.html

changebar: $(NAME).txt
	changebar $(NAME).txt $(PRIOR).txt

less: trigger $(NAME).txt changebar
	less $(NAME).txt.bar

checkxml:
	for f in src/*.xml; do tidy -e -q -xml $$f ; done

# TODO: enumerate all source files
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

colorize: $(NAME).html
	./tools/decorate.py global $(NAME).html > color_global.html
	./tools/decorate.py traffic $(NAME).html > color_traffic.html
	./tools/decorate.py model $(NAME).html > color_model.html



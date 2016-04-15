NAME=draft-ietf-ippm-model-based-metrics
TARGETS=$(NAME).txt $(NAME).html
TARGETS=$(NAME).html $(NAME).txt
# Doc and thie Makefile MUST NOT contain any Google private information
# and must be in gmail (not corp) "anybody with URL can access"
# DOCID=1-WxkTWGuMV0hxdXT4Z_a5XpoZEXxeLUA618_8jpyP_A
WEBNAME=draft-ietf-ippm-model-based-metrics
# Make file below a link to the most recent published version
PRIOR=prior
WEBDIR=${HOME}/Downloads
WEBDIR=${HOME}/www/drafts
# BUILDKIT permits compilation on any unix like system
BUILDKIT=MBM_buildkit.tgz
FORMATTED=`date`
LIB='XML_LIBRARY='${PWD}

.SUFFIXES:
.SUFFIXES: .stamp .tex .pdf

top: all

recompile: $(TARGETS)

stage: $(NAME).txt $(NAME).html ${BUILDKIT}
	cp $(NAME).txt ${WEBDIR}/${WEBNAME}.txt
	cp $(NAME).xml ${WEBDIR}/${WEBNAME}.xml
	cp $(NAME).html ${WEBDIR}/${WEBNAME}.html
	cp ${BUILDKIT} ${WEBDIR}/
	chmod 644 ${WEBDIR}/${WEBNAME}*

buildkit ${BUILDKIT}:
	tar czvf ${BUILDKIT} decorateMBM decorate.py Makefile Pub References

all: trigger $(TARGETS)

trigger $(NAME).trig:
	touch $(NAME).trig

clean:
	rm -f $(NAME).trig $(NAME).tmp $(NAME).xml $(NAME).pdf $(NAME).txt $(NAME).html $(NAME).txt.bar ${BUILDKIT}

changebar: $(NAME).txt
	changebar  $(NAME).txt $(PRIOR).txt

less: trigger $(NAME).txt changebar
	less $(NAME).txt.bar

# This fetches the shared source from Google docs
$(NAME).xml: PRIOR.$(NAME).xml $(NAME).trig
	cat PRIOR.$(NAME).xml | sed  -e "s/FORMATTED/$(FORMATTED)/g" -e '/<\/rfc>/q' -e '/%/a\\ ' > $(NAME).xml

$(NAME).pdf: $(NAME).xml
	-echo Making $(NAME).pdf ======
	export $(LIB); xml2pdf $(NAME).xml

$(NAME).txt: $(NAME).xml
	-echo Making $(NAME).txt ======
	export $(LIB); xml2rfc $(NAME).xml

$(NAME).html: $(NAME).xml
	-echo Making $(NAME).html and $(NAME).color.html ======
	export $(LIB); xml2html $(NAME).xml
#	./decorate.py $(NAME).html > color.html



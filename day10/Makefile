.PHONY: test clean update

test : expected.txt results.txt
	diff expected.txt results.txt && echo results MATCH

PROGRAMS = one.awk two.awk
INPUTS = sample.txt sample2.txt sample3.txt sample4.txt sample5.txt sample6.txt input.txt

results.txt : $(PROGRAMS) $(INPUTS)
	./one.awk sample.txt > $@
	./one.awk sample2.txt >> $@
	./one.awk sample3.txt >> $@
	./one.awk sample4.txt >> $@
	./one.awk sample5.txt >> $@
	./one.awk sample6.txt >> $@
	./one.awk input.txt >> $@
	./two.awk sample.txt >> $@
	./two.awk sample2.txt >> $@
	./two.awk sample3.txt >> $@
	./two.awk sample4.txt >> $@
	./two.awk sample5.txt >> $@
	./two.awk sample6.txt >> $@
	./two.awk input.txt >> $@
	cat $@

clean:
	$(RM) results.txt

update: results.txt
	cp $< expected.txt

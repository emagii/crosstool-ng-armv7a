ifneq	("$(CROSS_COMPILE)","arm-linux-")
hello:
	@echo	"You must setup your toolchain first"
	@echo	CROSS_COMPILE=$(CROSS_COMPILE)
else
CC=$(CROSS_COMPILE)gcc

hello:	hello.c
	$(CC)	-o	$@	hello.c
endif

clean:
	rm	-f	hello

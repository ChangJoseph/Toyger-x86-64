BYACC=/opt/cec/bin/yacc32-1.15
JFLEX=./jflex-full-1.7.0.jar

p4_java: p4_java.java lexer.java
	javac -classpath "" *.java

lexer.java: p4_java.l
	java -jar $(JFLEX) --legacydot p4_java.l 

p4_java.java: p4_java.y
	$(BYACC) -Jclass=p4_java p4_java.y

clean:
	rm -f lexer.java lexer.java~ p4_java*.class p4_java*.java lexer.class


# redir-y.tst: yash-specific test of redirections

exec 3>&- 4>&- 5>&- 6>&- 7>&- 8>&- 9>&-

echo in0 >in0
echo in1 >in1
echo 'in*' >'in*'

echo PS1= >yashrc

test_oE -e 0 \
    'pathname expansion in redirection operand (non-POSIX, interactive), success'\
    -i +m --rcfile=yashrc
cat <i*0
__IN__
in0
__OUT__

test_O -d -e 2 \
    'pathname expansion in redirection operand (non-POSIX, interactive), failure' \
    -i +m --rcfile=yashrc
cat <in*
__IN__

(
posix="true"
export ENV=yashrc

test_oE -e 0 'pathname expansion in redirection operand (POSIX, interactive)' \
    -i +m
cat <i*0
cat <in* # multiple matches: the pattern is left intact
__IN__
in0
in*
__OUT__

)

test_oE -e 0 'tilde expansion not performed in here-document operand'
HOME=/home
cat <<~
/home
~
__IN__
/home
__OUT__

test_oE -e 0 'parameter expansion not performed in here-document operand'
foo=FOO
cat <<$foo
FOO
$foo
__IN__
FOO
__OUT__

test_oE -e 0 'command substitution not performed in here-document operand'
cat <<$(echo foo)`echo bar`
foobar
$(echo foo)`echo bar`
__IN__
foobar
__OUT__

test_oE -e 0 'arithmetic expansion not performed in here-document operand'
cat <<$((1+1))
foo
$((1+1))
__IN__
foo
__OUT__

test_oE -e 0 'duplicating input to the same file descriptor'
echo foo | cat <&0
__IN__
foo
__OUT__

test_oE -e 0 'duplicating output to the same file descriptor'
echo foo >&1
__IN__
foo
__OUT__

# Test various file descriptor combinations to ensure the shell correctly
# "dup"s the pipe file descriptors after opening a pipe.
test_oE 'pipe redirection'
exec 4>>|3; echo 4-3 >&4; exec 4>&-; cat <&3; exec 3<&-
exec 4>>|6; echo 4-6 >&4; exec 4>&-; cat <&6; exec 6<&-
exec 5>>|3; echo 5-3 >&5; exec 5>&-; cat <&3; exec 3<&-
exec 5>>|6; echo 5-6 >&5; exec 5>&-; cat <&6; exec 6<&-
exec 5>>|4; echo 5-4 >&5; exec 5>&-; cat <&4; exec 4<&-
exec 3>>|6; echo 3-6 >&3; exec 3>&-; cat <&6; exec 6<&-
exec 3>>|4; echo 3-4 >&3; exec 3>&-; cat <&4; exec 4<&-
exec 9>&1
exec  >>|0; echo 1-0    ; exec  >&9; cat <&0;
__IN__
4-3
4-6
5-3
5-6
5-4
3-6
3-4
1-0
__OUT__

test_oE 'using pipe redirection in subshell'
exec 3>&1
{
    while read -r i && [ "$i" -lt 5 ]; do
	echo "$i" >&3
	echo "$((i+1))"
    done | {
	echo 0
	cat -u
    }
} >>|0
__IN__
0
1
2
3
4
__OUT__

test_oE -e 0 'input command redirection' -e
cat <(echo foo)
cat <(echo bar)-
__IN__
foo
bar
__OUT__

test_oE -e 0 'output command redirection' -e
echo >(read i && echo $((i+1)))99 | cat
# "cat" ensures the output is flushed before the shell exits
__IN__
100
__OUT__

test_oE -e 0 'command redirection is run in subshell' -e
i=0
echo >(read i && echo $((i+1))) 99 | cat
# "cat" ensures the output is flushed before reaching this line
echo $i
__IN__
100
0
__OUT__

test_x -e 0 'exit status of command redirection is ignored'
<(false) >(false)
__IN__

test_oE -e 0 'empty here-string'
cat <<<""
__IN__

__OUT__

test_oE -e 0 'tilde expansion in here-string'
HOME=/home
cat <<<~/foo
__IN__
/home/foo
__OUT__

test_oE -e 0 'double quotation and parameter expansion in here-string'
foo=FOOOO
cat <<<"${foo%OO}"
__IN__
FOO
__OUT__

test_oE -e 0 'multi-line here-string'
cat <<<'1
2'
__IN__
1
2
__OUT__

test_oE -e 0 'space after here-string operator'
cat <<< foo
__IN__
foo
__OUT__

test_oE -e 0 'here-string with non-default file descriptor'
cat 3<<<foo <&3
__IN__
foo
__OUT__

test_Oe -e 2 'missing target for <'
<
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for <>'
<>
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for <& (EOF)'
<&
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for <& (line continuation and comment)'
<&\
    #
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for >'
>
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for >|'
>|
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for >&'
>&
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for >>'
>>
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for >>|'
>>|
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing target for <<<'
<<<
__IN__
syntax error: the redirection target is missing
__ERR__

test_Oe -e 2 'missing delimiter after <<'
<<
__IN__
syntax error: the end-of-here-document indicator is missing
__ERR__

test_Oe -e 2 'missing delimiter after <<-'
<<-
__IN__
syntax error: the end-of-here-document indicator is missing
__ERR__

test_Oe -e 2 'newline in end-of-here-document indicator'
<<'
'
__IN__
syntax error: the end-of-here-document indicator contains a newline
__ERR__

test_oE -e 0 'missing here-document delimiter'
cat <<END
foo
__IN__
foo
__OUT__
: <<END
END

test_O -d -e 2 'space between < and ( in command redirection'
< (:)
__IN__

# TODO: yash is broken
: <<__END__
test_Oe -e 2 'unclosed input command redirection'
echo not printed <(
__IN__
syntax error: unclosed command redirection
__ERR__

test_Oe -e 2 'unclosed output command redirection'
echo not printed >(
__IN__
syntax error: unclosed command redirection
__ERR__
__END__

# vim: set ft=sh ts=8 sts=4 sw=4 noet:

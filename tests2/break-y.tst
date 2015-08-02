# break-y.tst: yash-specific test of the break built-in

test_oE 'breaking iteration, unnested, short option'
eval -i 'echo 1' \
    '(exit 13); break -i; echo not reached 1' \
    'echo not reached 2'
echo $?
__IN__
1
13
__OUT__

test_oE 'breaking iteration, unnested, long option'
eval -i 'echo 1' \
    '(exit 13); break --iteration; echo not reached 1' \
    'echo not reached 2'
echo $?
__IN__
1
13
__OUT__

test_oE 'breaking nested iteration'
eval -i 'eval -i "break -i" "echo not reached"; echo broke'
__IN__
broke
__OUT__

test_OE 'breaking loop out of iteration'
for i in 1; do
    eval -i break 'echo not reached 1'
    echo not reached 2
done
__IN__

test_OE 'breaking iteration out of eval'
eval -i 'eval "break -i"; echo not reached 1' 'echo not reached 2'
__IN__

echo 'break -i' >break

test_OE 'breaking iteration out of dot'
eval -i '. ./break; echo not reached 1' 'echo not reached 2'
__IN__

test_OE 'breaking iteration out of loop'
eval -i 'for i in 1; do break -i; done; echo not reached 1' \
    'echo not reached 2'
__IN__

test_Oe -e n 'breaking without target loop'
break
__IN__
break: not in a loop
__ERR__

test_Oe -e n 'breaking without target iteration'
break -i
__IN__
break: not in an iteration
__ERR__

test_Oe -e n 'too many operands'
break 1 2
__IN__
break: too many operands are specified
__ERR__

test_Oe -e n 'operand and -i'
break -i 1
__IN__
break: no operand is expected
__ERR__

test_Oe -e n 'invalid option'
break --no-such-option
__IN__
break: `--no-such-option' is not a valid option
__ERR__

# vim: set ft=sh ts=8 sts=4 sw=4 noet:

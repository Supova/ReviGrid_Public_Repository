clear
main(0)
pause(2)


for i = 1:inf
    gen.call("setPWM", [255 0]);
    pause(3)
    gen.call("setPWM", [0 0]);
    pause(3)

end
local thirst = require("thirst")

thirst.run_folder("folder_test", "/inner/.*")

function love.keypressed(k)
	if k == "r" then love.event.quit("restart") end
	if k == "q" then love.event.quit() end
end

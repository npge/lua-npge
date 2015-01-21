describe("util.timer", function()
    it("measures time spent by functions", function()
        local f = function(x)
            return x * 10
        end
        local module = {
            f = f,
        }
        assert.equal(module.f(42), 420)
        local timer = require 'npge.util.timer'
        timer.wrap(module)
        assert.equal(module.f(42), 420)
        local spent_time = timer.spentTime(module)
        assert.equal(type(spent_time['f']), 'number')
        timer.unwrap(module)
        assert.equal(module.f(42), 420)
    end)
end)

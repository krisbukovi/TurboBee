local obj1 = require('abs')

describe('a simple test', function()
    it('adds 1 + 1', function()
        local result = obj1.add(1,1)
        assert.is_true(result == 2)
    end)
end)
 
describe("openresty script", function()
  it("should run in ngx_lua context", function()
    assert.truthy(_G.ngx)
    assert.equal(0, ngx.OK)
    assert.equal(200, ngx.HTTP_OK)
  end)
  it("should wait", function()
    ngx.sleep(3)
    assert.is_true(1 == 1)
  end)
end)

describe("mocks", function()
  it("replaces a table with spies", function()
    local t = {
      thing = function(msg) ngx.say(msg) end
    }

    local m = mock(t) -- mocks the table with spies, so it will print

    m.thing("Coffee")
    assert.spy(m.thing).was.called_with("Coffee")
  end)

  it("replaces a table with stubs", function()
    local t = {
      thing = function(msg) ngx.say(msg) end
    }

    local m = mock(t, true) -- mocks the table with stubs, so it will not print

    m.thing("Coffee")
    assert.stub(m.thing).was.called_with("Coffee")
    mock.revert(m) -- reverts all stubs/spies in m
    m.thing("Tea") -- DOES print 'Tea'
  end)

  it('pgmoon', function()
      local thing = require('pgmoon')
      spy.on(thing, 'new')
      local thing2 = thing.new({
      host = os.getenv("DATABASE_HOST"),
      port = os.getenv("DATABASE_PORT"),
      database = os.getenv("DATABASE_NAME"),
      user = os.getenv("DATABASE_USER"),
      password = os.getenv("DATABASE_PASSWORD")
      })

      local t = {
        f1 = function() thing2:connect() end 
      }

      local m = mock(t)

      m.f1()

      assert.spy(m.f1).was.called()

      --assert.spy(thing.new).was.called()

      --spy.on(thing2, 'connect')
      --thing2:connect(100,10)
      --assert.spy(thing.new).was.called_with('Hi!')

      --assert.spy(thing2.connect).was.called()
      --assert.spy(thing2.connect).was.called_with(100,10)
      end)

  it('spies on nginx', function()
    spy.on(ngx, 'say')
    ngx.say('Hi!')

    assert.spy(ngx.say).was.called()
    -- assert.spy(thing.greet).was.called_with('Hi!')
  end)
end)

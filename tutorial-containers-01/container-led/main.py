import qwiic_button
import fastapi
import uvicorn

app = fastapi.FastAPI()

@app.post("/{state}")
async def root(state: bool) -> None:
    if state==True:
        app.state.my_button.LED_on(255)
    else:
        app.state.my_button.LED_off()
    
@app.on_event('startup')
async def server_startup():
    app.state.my_button = qwiic_button.QwiicButton()

uvicorn.run('main:app', host="0.0.0.0", port=80, reload=True, debug=True)
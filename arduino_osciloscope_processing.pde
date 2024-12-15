/*
 * Este programa es software libre: puede redistribuirlo y/o modificarlo
* bajo los términos de la Licencia Pública General GNU publicada por
* la Free Software Foundation, ya sea la versión 3 de la Licencia, o
* (a su elección) cualquier versión posterior.
*
* Este programa se distribuye con la esperanza de que sea útil,
* pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
* COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Vea la
* Licencia Pública General GNU para más detalles.
*
* Debería haber recibido una copia de la Licencia Pública General GNU
* junto con este programa. Si no es así, vea <http://www.gnu.org/licenses/>.
*/

import processing.serial.*;

Serial port;  // Creado objeto dede la clase Serial
int val;      // Data received from the serial port
int[] values;
float zoom;

void setup() 
{
  size(1280, 480);
  // Open the port that the board is connected to and use the same speed (9600 bps)
  port = new Serial(this, Serial.list()[0], 9600);
  values = new int[width];
  zoom = 1.0f;
  smooth();
}

int getY(int val) {
  return (int)(height - val / 1023.0f * (height - 1));
}

int getValue() {
  int value = -1;
  while (port.available() >= 3) {
    if (port.read() == 0xff) {
      value = (port.read() << 8) | (port.read());
    }
  }
  return value;
}

void pushValue(int value) {
  for (int i=0; i<width-1; i++)
    values[i] = values[i+1];
  values[width-1] = value;
}
 
void drawLines() {
  stroke(255);
  
  int displayWidth = (int) (width / zoom);
  
  int k = values.length - displayWidth;
  
  int x0 = 0;
  int y0 = getY(values[k]);
  for (int i=1; i<displayWidth; i++) {
    k++;
    int x1 = (int) (i * (width-1) / (displayWidth-1));
    int y1 = getY(values[k]);
    line(x0, y0, x1, y1);
    x0 = x1;
    y0 = y1;
  }
}
 
void drawGrid() {
  stroke(255, 0, 0);
  line(0, height/2, width, height/2);
}
 
void keyReleased() {
  switch (key) {
    case '+':
      zoom *= 2.0f;
      println(zoom);
      if ( (int) (width / zoom) <= 1 )
        zoom /= 2.0f;
      break;
    case '-':
      zoom /= 2.0f;
      if (zoom < 1.0f)
        zoom *= 2.0f;
      break;
  }
}
 
void draw()
{
  background(0);
  drawGrid();
  val = getValue();
  if (val != -1) {
    pushValue(val);
  }
  drawLines();
}

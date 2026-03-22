//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
//---------------------------[[[[[[JI]]]]]]----------------------------\\
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
#property copyright   "JesúsIgnacio"
#property link        "https://github.com/JesusIgnacioM"
#property version     "1.00"
#property description "Las velas y barras cambian de colores constantemente, muestra sus valores en los distintos colores, se puede desactivar sin quitar el indicador."
#property indicator_chart_window
#property indicator_plots 0


input int TiempoMs = 40; //--- Frecuencia en milisegundos 
input color Fondo = clrBlack; //--- Cambia el color del fondo

input int PasoColor = 5; //--- En cada frecuencia, cuantos valores R, G o B, suben o bajan      
string NombreBoton = "RGB";
string EtiquetaP = "MonitorRGB";

//--- Variables de color ---\\
int R = 255, G = 0, B = 0, FASE = 0;
bool RGBActivo = true;

//---------------------------------------------------------------------\\
//--- Inicialización, unicamente se ejecuta una vez ---\\
int OnInit() 
{
   EventSetMillisecondTimer(TiempoMs); //--- Cada cuanto debe ejecutarse la función OnTimer
   CrearObjeto(NombreBoton, OBJ_BUTTON, 200, 60, 130, 28, "⚡ RGB: ON"); //--- Botón Principal
   
//--- Etiquetas de Monitor (R, G, B) ---\\

// --- Etiquetas para Alcistas (BULL) ---\\
   CrearObjeto(EtiquetaP+"BULL_TXT", OBJ_LABEL, 540, 55, 0, 0, "BULL ▲");
   CrearObjeto(EtiquetaP+"BULL_R",   OBJ_LABEL, 470, 55, 0, 0, "R: 255");
   CrearObjeto(EtiquetaP+"BULL_G",   OBJ_LABEL, 400, 55, 0, 0, "G: 0");
   CrearObjeto(EtiquetaP+"BULL_B",   OBJ_LABEL, 330, 55, 0, 0, "B: 0");

// --- Etiquetas para Bajistas (BEAR) ---\\
   CrearObjeto(EtiquetaP+"BEAR_TXT", OBJ_LABEL, 540, 30, 0, 0, "BEAR ▼");
   CrearObjeto(EtiquetaP+"BEAR_R",   OBJ_LABEL, 470, 30, 0, 0, "R: 0");
   CrearObjeto(EtiquetaP+"BEAR_G",   OBJ_LABEL, 400, 30, 0, 0, "G: 255");
   CrearObjeto(EtiquetaP+"BEAR_B",   OBJ_LABEL, 330, 30, 0, 0, "B: 255");
   
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, Fondo);
   
   return(INIT_SUCCEEDED);
}
//---------------------------------------------------------------------\\
// 
void CrearObjeto(string Nombre, ENUM_OBJECT Tipo, int x, int y, int TamanoX, int TamanoY, string Texto) 
{
   if(ObjectFind(0, Nombre) < 0) ObjectCreate(0, Nombre, Tipo, 0, 0, 0); //--- Si ObjectFind devuelve menos de 0, significa que el objeto no existe, así que se crea
//--- Ubicación ---\\
   ObjectSetInteger(0, Nombre, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, Nombre, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, Nombre, OBJPROP_YDISTANCE, y);
//--- Apariencia del texto ---\\
   ObjectSetString(0, Nombre, OBJPROP_TEXT, Texto);
   ObjectSetInteger(0, Nombre, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, Nombre, OBJPROP_FONT, "Consolas"); //--- Tipografía del texto
//--- Tamaño del botón ---\\
   if(Tipo == OBJ_BUTTON) 
   {
      ObjectSetInteger(0, Nombre, OBJPROP_XSIZE, TamanoX);
      ObjectSetInteger(0, Nombre, OBJPROP_YSIZE, TamanoY);
      ObjectSetInteger(0, Nombre, OBJPROP_STATE, true); //--- Queda ejecutado
   }
}
//---------------------------------------------------------------------\\
//--- Que ocurre al quitar el indicador ---\\
void OnDeinit(const int reason) 
{
   EventKillTimer();
   ObjectDelete(0, NombreBoton); 
   ObjectsDeleteAll(0, EtiquetaP); 
   ResetColores();
   ChartRedraw();
}
//---------------------------------------------------------------------\\
//--- Almacena los valores que se pondrán quitar el indicador ---\\
void ResetColores() 
{
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrGreen);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrGreen);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrRed);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrRed);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrDarkGray);
}
//---------------------------------------------------------------------\\
//--- Interación con el botón ---\\
void OnChartEvent(const int Identificador, const long &lparam, const double &dparam, const string &sparam) 
{
   if(Identificador == CHARTEVENT_OBJECT_CLICK && sparam == NombreBoton) //--- Al precionar el botón ejecuta el resto sino ignorar
   {
      RGBActivo = (bool)ObjectGetInteger(0, NombreBoton, OBJPROP_STATE); //--- El botón está encendido o apagado
      if(!RGBActivo) 
      {
         ObjectSetString(0, NombreBoton, OBJPROP_TEXT, "💤 RGB: OFF");
         ResetColores();
      } 
      else ObjectSetString(0, NombreBoton, OBJPROP_TEXT, "⚡ RGB: ON");
      ChartRedraw();
   }
}
//---------------------------------------------------------------------\\
//--- Se ejecuta cada ms determinados por la frecuencia ---\\
void OnTimer() 
{
   if(!RGBActivo) return; //--- Si no es cierto el código se detine aquí
   switch(FASE) //--- Que color aumenta y que color disminuye

   {
      case 0: G += PasoColor; if(G >= 255) { G = 255; FASE = 1; } break; //--- Rojo lleno, sube verde y va a fase 1
      case 1: R -= PasoColor; if(R <= 0)   { R = 0;   FASE = 2; } break; //--- Verde lleno, baja rojo y va a fase 2
      case 2: B += PasoColor; if(B >= 255) { B = 255; FASE = 3; } break; //--- Solo verde, sube azul y va a fase 3
      case 3: G -= PasoColor; if(G <= 0)   { G = 0;   FASE = 4; } break; //--- Azul lleno, baja verde y va a fase 4
      case 4: R += PasoColor; if(R >= 255) { R = 255; FASE = 5; } break; //--- Solo azul, sube rojo y va a fase 5
      case 5: B -= PasoColor; if(B <= 0)   { B = 0;   FASE = 0; } break; //--- Rojo lleno, baja azul y regresa a fase 0
   }

//--- Crea un tipo de texto y convierte dicho texto en un color real ---\\
   color ColorBull = StringToColor(StringFormat("%d,%d,%d", R, G, B));
   color ColorBear = StringToColor(StringFormat("%d,%d,%d", 255-R, 255-G, 255-B)); //--- Invierte los colores para Bear

//--- Aplicar al gráfico el cambio de colores ---\\
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, ColorBull);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, ColorBull);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, ColorBull); //--- Las líneas reciben el mismo color que Bull
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, ColorBear);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, ColorBear);

//--- Actualizar Monitor ---\\
   
//--- Texto, "Bull" y "Bear" con sus respectivos colores dinámicos ---\\
   ObjectSetInteger(0, EtiquetaP+"BULL_TXT", OBJPROP_COLOR, ColorBull);
   ObjectSetInteger(0, EtiquetaP+"BEAR_TXT", OBJPROP_COLOR, ColorBear);
   ObjectSetInteger(0, NombreBoton, OBJPROP_BGCOLOR, ColorBull);

//--- Valores RGB de Bull (Letras fijas R=Rojo, G=Verde, B=Azul) ---\\
   ObjectSetString(0, EtiquetaP+"BULL_R", OBJPROP_TEXT, "R: " + (string)R);
   ObjectSetInteger(0, EtiquetaP+"BULL_R", OBJPROP_COLOR, clrRed);
   ObjectSetString(0, EtiquetaP+"BULL_G", OBJPROP_TEXT, "G: " + (string)G);
   ObjectSetInteger(0, EtiquetaP+"BULL_G", OBJPROP_COLOR, clrLime);
   ObjectSetString(0, EtiquetaP+"BULL_B", OBJPROP_TEXT, "B: " + (string)B);
   ObjectSetInteger(0, EtiquetaP+"BULL_B", OBJPROP_COLOR, clrDodgerBlue);

//--- Valores RGB de Bear (Inversos) ---\\
   ObjectSetString(0, EtiquetaP+"BEAR_R", OBJPROP_TEXT, "R: " + (string)(255-R));
   ObjectSetInteger(0, EtiquetaP+"BEAR_R", OBJPROP_COLOR, clrRed);
   ObjectSetString(0, EtiquetaP+"BEAR_G", OBJPROP_TEXT, "G: " + (string)(255-G));
   ObjectSetInteger(0, EtiquetaP+"BEAR_G", OBJPROP_COLOR, clrLime);
   ObjectSetString(0, EtiquetaP+"BEAR_B", OBJPROP_TEXT, "B: " + (string)(255-B));
   ObjectSetInteger(0, EtiquetaP+"BEAR_B", OBJPROP_COLOR, clrDodgerBlue);

   ChartRedraw();
}
//---------------------------------------------------------------------\\
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[],
                const double &close[], const long &tick_volume[], const long &spread[],
                const int &real_volume[]) { return(rates_total); }
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
//---------------------------------------------------------------------\\
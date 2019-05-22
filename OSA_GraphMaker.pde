import java.util.*;
import java.io.File;
import controlP5.*;
import grafica.*;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;
import java.util.Random;
import javax.swing.JFileChooser;
import javax.swing.filechooser.FileNameExtensionFilter;

ControlP5 cp5;
ControlP5 cp6;
ControlP5 cp7;

GPlot plot1; 
GPointsArray points;

File file; 
boolean FileSel = false;
Boolean init = false;

String[] osaRawData;
String[] osaParsed = new String [30];

String[] wlBins = new String[3648];
String[][] sData = new String[10000][3648];

GPointsArray sNum = new GPointsArray(3648);

     
int recordNum = 0;
int sliderTicks2 = 0;
int lastRecord = 0;
int filecount = 0;
int lastValue = 0;

int wlLowCnt = 2;
int wlHighCnt = 3647;

float wlLowA = 944.0;
float wlHighA = 1101.0;

ScrollableList list;

void setup() {
  size(1280,700);
  //fullScreen();
  background(0);
 
  cp5 = new ControlP5(this);
  ControlFont cf1 = new ControlFont(createFont("Arial",10));

  cp5.addButton("Save")
     .setBroadcast(false)
     .setValue(999)
     .setPosition(width-50,height-15)
     .setSize(50,15)  
     .setFont(cf1)
     .setBroadcast(true)
   ;
   
   
  cp6 = new ControlP5(this);
  cp6.addButton("Load")
     .setBroadcast(false)
     .setValue(999)
     .setPosition(width-100,height-15)
     .setSize(50,15)  
     .setFont(cf1)
     .setBroadcast(true)
   ;
   
  cp7 = new ControlP5(this);
  cp7.addButton("Redraw")
     .setBroadcast(false)
     .setValue(999)
     .setPosition(width-150,height-15)
     .setSize(50,15)  
     .setFont(cf1)
     .setBroadcast(true)
   ;
   
   

           
  loadFile();
  loadData();
  setupButtons();
  addData(0); 
             
}

void draw() {
 background(255); 
 fill(0);
 textSize(16);
 textAlign(CENTER);
 text("Sample #: " + sliderTicks2 + " of " + sData.length + "      Time: " + sData[sliderTicks2][0],width/2,height-75);
 
 if (lastValue != sliderTicks2) {
   addData(sliderTicks2);
   lastValue = sliderTicks2;
   fill(0);
   textSize(16);
 }
 
 drawChart(); 
 
}



void setupButtons() {

    ControlFont cf1 = new ControlFont(createFont("Arial",10));
  
     cp5.addSlider("sliderTicks2")
     .setPosition(width/2-300,height - 40)
     .setWidth(600)
     .setHeight(30)
     .setRange(2,sData.length-1) 
     .setValue(0)
     .setNumberOfTickMarks(sData.length-1)
     .setSliderMode(Slider.FLEXIBLE)
   ;

  
     cp5.addNumberbox("wlLow")
     .setPosition(75,height-125)
     .setSize(100,40)
     .setFont(new ControlFont(createFont("Arial",18)))
     .setMultiplier(1)
     //.setRange(944.0,1101.0)
     .setScrollSensitivity(.01)
     .setValue(wlLowA)
     .setColorCaptionLabel(0)
     .setCaptionLabel("Low Wavelength")
     .setDecimalPrecision(1)
     ;
     
     cp5.addNumberbox("wlHigh")
     .setPosition(width -125,height-125)
     .setSize(100,40)
     .setFont(cf1)
     .setMultiplier(1)
     //.setRange(944.0,1101.0)
     .setScrollSensitivity(.01)
     .setValue(wlHighA)
     .setColorCaptionLabel(0)
     .setCaptionLabel("High Wavelength")
     .setDecimalPrecision(1)
     ;         

  
}







void drawChart() {
  plot1.beginDraw();
  plot1.drawBackground();
  plot1.drawBox();
  plot1.drawGridLines(GPlot.VERTICAL);
  plot1.drawGridLines(GPlot.HORIZONTAL);
  plot1.drawXAxis();
  plot1.drawYAxis();
  plot1.drawTopAxis();
  plot1.drawRightAxis();
  plot1.drawTitle();
  plot1.drawLines();
  plot1.drawLabels();
  plot1.activatePointLabels();
  plot1.endDraw();
}


void loadFile() {
  JFileChooser fileChooser = new JFileChooser();
  FileNameExtensionFilter filter = new FileNameExtensionFilter("OSA_Data","txt");
  fileChooser.setCurrentDirectory(new java.io.File(""));
  fileChooser.setDialogTitle("Choose Spectra File");
  fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
  fileChooser.setFileFilter(filter);
   
          if (fileChooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
              FileSel = true;
              file = (fileChooser.getSelectedFile());
          } else {
              println("No Selection ");
              exit();
              FileSel = false;
          }
  init = true;
 
}

void loadData() {
  
             boolean mainDataFound = false;
             int maindataLocation = 0;
             boolean dataReady = false;
  
             int r = 0;
             osaRawData = loadStrings(file);
             sData = new String[osaRawData.length-1][3648];
             for (int i = 0; i <= (osaRawData.length-1); i++) {
                    if (dataReady) { 
                      sData[r] = split(osaRawData[i],"\t");
                      r++;
                    }else{
                        if (mainDataFound) {
                           wlBins = split(osaRawData[i],"\t");
                           dataReady = true;
                        }else{
                            if (osaRawData[i].length() > 28) {
                               if (">>>>>Begin Spectral Data<<<<<".equals(osaRawData[i].substring(0,29))) {
                                  maindataLocation = i; 
                                  mainDataFound = true;
                                     }                     
                                       }
                                     } 
                    } 
               }
               
   
}



void Save() {
     save(file + "_" + filecount + "_" + sliderTicks2 + ".jpg");
     filecount++;
}

void Load() {
  loadFile();
  loadData();
  setupButtons();
  addData(0);
}

void Redraw() {
  println("Redraw");
  loadData();
  setupButtons();
  addData(0);
}


void addData(int set) {
          GPointsArray sNum = new GPointsArray(3648);

                  for(int i = wlLowCnt;i < wlHighCnt; i++){  
                    try{
                    sNum.add(i,float(sData[set][i]),sData[set][i]);
                    } catch(NullPointerException e) {}
                   }
  
                plot1 = new GPlot(this);
                plot1.setPos(0,0);
                plot1.setOuterDim(width,height-100);
                // Set the plot title and the axis labels
                plot1.setTitleText("Measured Spectrum");
                plot1.getXAxis().setAxisLabelText("Bins");
                plot1.getYAxis().setAxisLabelText("Counts");
                plot1.getXAxis().setNTicks(10);
                plot1.setLogScale("y");
                float pSize = 2.0;
                plot1.setPointSize(pSize);
                plot1.addLayer("layer 1", sNum);
                plot1.getLayer("layer 1").setLineColor(color(0, 0, 0));
                plot1.activatePanning();
                plot1.activateZooming(1.1, CENTER, CENTER);
                plot1.activatePointLabels();
                plot1.setPoints(sNum); 
 
}


void wlLow(float wl) {
  wlLowA = wl;
  if (wlLowA < 944.0) {wlLowA = 944.0;};
  if (wlLowA > wlHighA) {wlLowA = wlHighA;};
  wlLowCnt = int(map(wlLowA,944.0,1101.0,2.0,3647.0));
}

void wlHigh(float wlx) {
  wlHighA = wlx;  
  if (wlHighA > 1101.0) {wlLowA = 1101.0;};
  if (wlHighA < wlLowA) {wlHighA = wlLowA;};
  wlHighCnt = int(map(wlHighA,944.0,1101.0,2.0,3647.0));
}

                           

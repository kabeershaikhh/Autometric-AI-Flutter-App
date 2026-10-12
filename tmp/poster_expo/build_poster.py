from pathlib import Path
from html import escape
import json
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, white
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'output' / 'poster'
OUT.mkdir(parents=True, exist_ok=True)
TEXT = (OUT / 'AutoMetric_AI_Poster_Text.txt').read_text(encoding='utf-8')
SECTIONS = {}
key = None
for line in TEXT.splitlines():
    if line in ['ABSTRACT', 'PROBLEM STATEMENT', 'AIM AND OBJECTIVES', 'PROPOSED SOLUTION', 'METHODOLOGY', 'RESULTS', 'TECHNOLOGIES USED', 'SUMMARY']:
        key = line
        SECTIONS[key] = []
    elif line == 'PROJECT DEMO':
        key = None
    elif key and line.strip():
        SECTIONS[key].append(line)

pdfmetrics.registerFont(TTFont('Arial', 'C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBold', 'C:/Windows/Fonts/arialbd.ttf'))
pdfmetrics.registerFontFamily('Arial',normal='Arial',bold='ArialBold',italic='Arial',boldItalic='ArialBold')
W, H = 1728, 4320
PRIMARY = HexColor('#7C4DFF')
DARK = HexColor('#2A2342')
BODY = HexColor('#5F5874')
LAVENDER = HexColor('#F3EEFF')
BORDER = HexColor('#D8C9FF')
M = 104
c = canvas.Canvas(str(OUT / 'AutoMetric_AI_Canva_Poster.pdf'), pagesize=(W,H), pageCompression=1)
c.setTitle('AutoMetric AI FYP Expo Poster')
c.setAuthor('AutoMetric AI Project Team')
layout = []

def rect(x,top,w,h,fill,stroke=None,r=0):
    c.setFillColor(fill)
    c.setStrokeColor(stroke or fill)
    c.setLineWidth(2)
    if r: c.roundRect(x,H-top-h,w,h,r,fill=1,stroke=int(stroke is not None))
    else: c.rect(x,H-top-h,w,h,fill=1,stroke=int(stroke is not None))

def line(x,y,x2,y2,color=BORDER,width=2):
    c.setStrokeColor(color)
    c.setLineWidth(width)
    c.line(x,H-y,x2,H-y2)

def para(text,x,top,w,size=35,leading=None,font='Arial',color=BODY,align=0,maxheight=None):
    style = ParagraphStyle('p', fontName=font, fontSize=size, leading=leading or size*1.35, textColor=color, alignment=align)
    p = Paragraph(text,style)
    aw,ah = p.wrap(w,H)
    if maxheight is not None and ah>maxheight: raise ValueError((text,ah,maxheight))
    if top+ah>H: raise ValueError('Page overflow')
    p.drawOn(c,x,H-top-ah)
    layout.append({'text':text,'x':x,'top':top,'width':w,'height':ah})
    return ah

def title(label,top):
    para(label,M,top,W-2*M,size=41,leading=49,font='ArialBold',color=PRIMARY)

def bullet(text,x,top,w,size=35,color=BODY):
    c.setFillColor(PRIMARY)
    c.circle(x+7,H-top-21,5.5,fill=1,stroke=0)
    return para(escape(text),x+31,top,w-31,size=size,color=color)

def gradient(top,height,colors):
    c.saveState()
    p = c.beginPath()
    p.rect(0,H-top-height,W,height)
    c.clipPath(p,stroke=0)
    c.linearGradient(0,H-top,W,H-top-height,[HexColor(z) for z in colors],extend=True)
    c.restoreState()

rect(0,0,W,H,white)
gradient(0,430,['#6333F3','#7C4DFF','#9E7BFF'])
c.saveState()
p = c.beginPath(); p.rect(0,H-430,W,430); c.clipPath(p,stroke=0)
c.setFillColor(white); c.setFillAlpha(.10)
c.circle(W-60,H-25,320,fill=1,stroke=0)
c.circle(18,H-425,190,fill=1,stroke=0)
c.restoreState()
rect(M,93,195,195,white,r=48)
c.drawImage(str(ROOT/'assets'/'AutoMetricAI.png'),M+26,H-93-169,width=143,height=143,mask='auto')
para('AutoMetric AI',M+249,85,W-M*2-249,size=112,leading=132,font='ArialBold',color=white)
para('AI Assisted Car Valuation<br/>and Maintenance',M+253,225,W-M*2-253,size=42,leading=55,color=white)
para("Built for Pakistan's used car market",M,357,W-2*M,size=31,color=white)

para('Price estimates in PKR',M,466,850,size=32,font='ArialBold',color=DARK)
para('Android and web',W-M-560,466,560,size=32,font='ArialBold',color=DARK,align=2)
line(M,529,W-M,529)

title('ABSTRACT',583)
para(escape(SECTIONS['ABSTRACT'][0]),M,653,W-2*M,size=36,leading=49,maxheight=260)

rect(0,959,W,332,LAVENDER)
title('PROBLEM STATEMENT',1001)
para(escape(SECTIONS['PROBLEM STATEMENT'][0]),M,1071,W-2*M,size=36,leading=49,maxheight=180)

title('AIM AND OBJECTIVES',1351)
para('<b>Aim:</b> Provide a locally relevant price reference and a simple way to manage vehicle upkeep.',M,1421,W-2*M,size=36,leading=49)
y=1548
for text in SECTIONS['AIM AND OBJECTIVES'][1:]:
    y += bullet(text[2:],M,y,W-2*M,size=35)+17

line(M,1804,W-M,1804)
title('PROPOSED SOLUTION',1858)
para(escape(SECTIONS['PROPOSED SOLUTION'][0]),M,1928,W-2*M,size=36,leading=49,maxheight=176)

rect(0,2157,W,578,LAVENDER)
title('METHODOLOGY',2200)
y=2277
for i,text in enumerate(SECTIONS['METHODOLOGY'],1):
    label,desc = text[3:].split(': ',1)
    para(f'{i:02d}',M,y,85,size=42,font='ArialBold',color=PRIMARY)
    h=para(f'<b>{escape(label)}:</b> {escape(desc)}',M+114,y+2,W-2*M-114,size=35,leading=45)
    y += max(h,52)+20
if y>2725: raise ValueError(('Methodology overflow',y))

title('RESULTS',2795)
para('9,849',M,2881,455,size=103,leading=117,font='ArialBold',color=PRIMARY)
para('prepared vehicle records',M,3014,420,size=33,leading=44,color=DARK)
line(M+494,2889,M+494,3134)
y=2878
for text in ['Price estimates on Android and web.', 'Saved valuations and a garage for multiple cars.', 'Service history and reminders using dates and updated mileage.']:
    y += bullet(text,M+540,y,W-2*M-540,size=35)+23
para(escape(SECTIONS['RESULTS'][-1]),M,3187,W-2*M,size=28,leading=39,color=BODY)

line(M,3261,W-M,3261)
title('TECHNOLOGIES USED',3310)
for x,t,label,desc in [
    (M,3380,'Flutter and Dart','Android and web interface'),
    (W/2+36,3380,'Python and XGBoost','Data preparation and price prediction'),
    (M,3505,'Firebase','Accounts and personal records'),
    (W/2+36,3505,'FastAPI and Docker','Prediction service and packaging')]:
    para(label,x,t,690,size=35,font='ArialBold',color=DARK)
    para(desc,x,t+51,690,size=30,leading=40,color=BODY)

rect(0,3680,W,284,LAVENDER)
title('SUMMARY',3719)
para(escape(SECTIONS['SUMMARY'][0]),M,3786,1100,size=34,leading=46,maxheight=150)
qr_x=W-M-206
para('PROJECT DEMO',qr_x-24,3695,254,size=26,font='ArialBold',color=PRIMARY,align=1)
rect(qr_x,3747,206,174,white)
c.setDash(8,6); c.setStrokeColor(PRIMARY); c.setLineWidth(2)
c.rect(qr_x,H-3747-174,206,174,fill=0,stroke=1); c.setDash()
para('Demo QR',qr_x+10,3808,186,size=25,color=BODY,align=1)

gradient(3964,356,['#5C2FE0','#6A3DE8','#7C4DFF'])
columns=[
    ('SUPERVISOR','Dr. Din Muhammad<br/>Sangrasi','',False),
    ('LEADER','Abdul Kabeer','22SW067',True),
    ('MEMBER','Mubashir Hussain','22SW061',True),
    ('MEMBER','Azhar Hussain','22SW110',True)]
col=(W-2*M)/4
for i,(role,name,roll,qr) in enumerate(columns):
    x=M+i*col
    para(role,x,3990,col,size=25,font='ArialBold',color=white,align=1)
    para(name,x+5,4037,col-10,size=31,leading=37,font='ArialBold',color=white,align=1)
    if roll: para(roll,x,4082,col,size=26,color=white,align=1)
    if qr:
        qx=x+(col-136)/2
        rect(qx,4132,136,126,white,r=8)
        para('LinkedIn<br/>QR',qx+5,4160,126,size=21,leading=28,color=BODY,align=1)
    else:
        para('Final Year Project',x,4166,col,size=25,color=white,align=1)
c.showPage(); c.save()
(ROOT/'tmp'/'poster_expo'/'layout.json').write_text(json.dumps(layout,indent=2),encoding='utf-8')
read=PdfReader(OUT/'AutoMetric_AI_Canva_Poster.pdf')
assert len(read.pages)==1
extracted=read.pages[0].extract_text()
for expected in ['ABSTRACT','METHODOLOGY','Abdul Kabeer','Mubashir Hussain','Azhar Hussain','9,849']:
    assert expected in extracted,expected
print('Created',OUT/'AutoMetric_AI_Canva_Poster.pdf')
print('Poster size 24 x 60 inches. Native selectable text. One page.')

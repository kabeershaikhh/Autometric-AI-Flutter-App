from pathlib import Path
from io import BytesIO
from html import escape
from reportlab.pdfgen import canvas
from reportlab.lib.colors import HexColor, white
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import Paragraph
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib.utils import ImageReader
from PIL import Image
from pypdf import PdfReader, PdfWriter, Transformation
from pypdf.generic import ContentStream, NameObject, FloatObject, ArrayObject

ROOT = Path(__file__).resolve().parents[2]
SOURCE = Path(r'C:/Users/PMLS/Downloads/Copy of FYP Poster (1).pdf')
OUT = ROOT/'output'/'pdf'/'AutoMetric_AI_Updated_Original_Template.pdf'
OUT.parent.mkdir(parents=True,exist_ok=True)
W,H=1728,4320
P=HexColor('#7C4DFF'); D=HexColor('#5C2FE0'); BODY=HexColor('#5F5874'); LIGHT=HexColor('#F3EEFF')
pdfmetrics.registerFont(TTFont('Arial','C:/Windows/Fonts/arial.ttf'))
pdfmetrics.registerFont(TTFont('ArialBold','C:/Windows/Fonts/arialbd.ttf'))
pdfmetrics.registerFontFamily('Arial',normal='Arial',bold='ArialBold',italic='Arial',boldItalic='ArialBold')
writer=PdfWriter(); writer.clone_document_from_reader(PdfReader(SOURCE)); writer.remove_text()
page=writer.pages[0]
keep={'/X5','/X8','/X10','/X11','/X28','/X30','/X35','/X36','/X37','/X38','/X12'}
stream=ContentStream(page.get_contents(),writer)
stream.operations=[(a,o) for a,o in stream.operations if not(o==b'Do' and str(a[0]) not in keep)]
# Canva exported the old bullet dots as filled paths rather than text glyphs.
# Remove those original body-colour fills so no obsolete bullet marks remain.
clean=[]; fill=(0,0,0)
for a,o in stream.operations:
    if o==b'rg': fill=tuple(round(float(z),4) for z in a)
    if o in (b'f',b'f*') and fill==(0.3922,0.4549,0.5451):
        clean.append(([],b'n'))
    else: clean.append((a,o))
stream.operations=clean
page[NameObject('/Contents')]=stream
palette={
    (0.451,0.8157,0.898):('#9E7BFF'),
    (0.0196,0.349,0.6118):('#5C2FE0'),
    (0.0471,0.7529,0.8745):('#7C4DFF'),
    (0.3412,0.6157,0.8118):('#9E7BFF'),
    (0.5804,0.949,0.8941):('#E6DCFF'),
}
def arr(color):
    z=HexColor(color)
    return ArrayObject([FloatObject(z.red),FloatObject(z.green),FloatObject(z.blue)])
def recolor(obj):
    cs=ContentStream(obj.get_contents() if hasattr(obj,'get_contents') else obj,writer)
    for a,o in cs.operations:
        if o in (b'rg',b'RG'):
            key=tuple(round(float(x),4) for x in a)
            if key in palette: a[:]=list(arr(palette[key]))
    if hasattr(obj,'get_contents'): obj[NameObject('/Contents')]=cs
    else: obj.set_data(cs.get_data())
recolor(page)
for name in keep:
    xo=page['/Resources']['/XObject'].get(name)
    if xo and xo.get_object().get('/Subtype')=='/Form': recolor(xo.get_object())
func=page['/Resources']['/XObject']['/X35'].get_object()['/Resources']['/Pattern']['/P34'].get_object()['/Shading'].get_object()['/Function'].get_object()
func[NameObject('/C0')]=arr('#7C4DFF'); func[NameObject('/C1')]=arr('#5C2FE0')
for key in ['/StructTreeRoot','/MarkInfo','/Outlines']:
    writer.root_object.pop(NameObject(key),None)
page.pop(NameObject('/Annots'),None)

buf=BytesIO(); c=canvas.Canvas(buf,pagesize=(W,H))
def para(text,x,top,w,size=32,leading=None,color=BODY,bold=False,align=0,maxh=None):
    ps=ParagraphStyle('text',fontName='ArialBold' if bold else 'Arial',fontSize=size,leading=leading or size*1.32,textColor=color,alignment=align)
    q=Paragraph(text,ps); _,height=q.wrap(w,H)
    if maxh and height>maxh: raise ValueError((text,height,maxh))
    q.drawOn(c,x,H-top-height)
    return height
def heading(text,top,x=200,w=1328,size=41):
    para(text,x,top,w,size=size,color=D,bold=True,align=1)
def bullet(text,x,top,w,size=34):
    c.setFillColor(P); c.circle(x+7,H-top-20,5,fill=1,stroke=0)
    return para(text,x+31,top,w-31,size)
def rect(x,top,w,h,fill=white,stroke=P,r=12):
    c.setFillColor(fill); c.setStrokeColor(stroke);c.setLineWidth(2.5)
    c.roundRect(x,H-top-h,w,h,r,fill=1,stroke=1)
def image_crop(file,x,top,w,h,crop=None,rounding=0):
    im=Image.open(file)
    iw,ih=im.size
    if crop:
        left,upper,right,lower=crop
    else: left,upper,right,lower=0,0,iw,ih
    scale=min(w/(right-left),h/(lower-upper))
    dw,dh=(right-left)*scale,(lower-upper)*scale
    dx=x+(w-dw)/2; dt=top+(h-dh)/2
    c.saveState(); path=c.beginPath()
    if rounding: path.roundRect(dx,H-dt-dh,dw,dh,rounding)
    else: path.rect(dx,H-dt-dh,dw,dh)
    c.clipPath(path,stroke=0)
    c.drawImage(ImageReader(im),dx-left*scale,H-dt-dh-(ih-lower)*scale,width=iw*scale,height=ih*scale,mask='auto')
    c.restoreState()

# The university logos and original section frames remain in the source PDF.
image_crop(ROOT/'assets'/'AutoMetricAI.png',92,36,170,170)
para('AutoMetric AI',35,292,W-70,136,147,white,True,1)
para('AI Assisted Car Valuation and Maintenance',80,433,W-160,48,58,white,False,1)

heading('ABSTRACT',552)
abstract="Buying or selling a used car often begins with one question: what is a reasonable asking price? AutoMetric AI uses vehicle listings from Pakistan to estimate prices from a car's specifications and mileage. Available on Android and web, it gives buyers and sellers a useful starting point for comparison and negotiation. Owners can also keep service records and plan upcoming maintenance in the same app."
para(escape(abstract),438,614,1218,31,39,maxh=258)
heading('PROBLEM STATEMENT',950)
para('Similar-looking cars can carry very different asking prices. Checking listings manually takes time, while differences in age, mileage and variant make comparisons difficult. Service records and maintenance deadlines are also easy to lose track of.',110,1020,1200,35,47,maxh=212)
heading('AIM AND OBJECTIVES',1330)
para('<b>Aim:</b> Provide a locally relevant price reference and a simple way to manage vehicle upkeep.',403,1400,1260,32,43,maxh=100)
para('<b>Objectives</b>',403,1507,1260,32,43)
y=1563
for t in ['Estimate prices using vehicle details and local listing data.','Save valuations for later comparison.','Organize service records and upcoming maintenance.']:
    y+=bullet(t,403,y,1260,31)+10

heading('METHODOLOGY',1813)
y=1887
for label,t in [('Collect','Gather used car listings from PakWheels.'),('Prepare','Clean and standardize vehicle data.'),('Develop','Compare models and select XGBoost.'),('Connect','Package the prediction API with Docker.'),('Build','Integrate Flutter with Firebase records.')]:
    y+=bullet(f'<b>{label}:</b> {t}',40,y,725,31)+14
if y>2275: raise ValueError(('Methodology overflow',y))
# Editable replacement of the other project's workflow diagram.
for x,label in [(838,'Flutter<br/>app'),(1095,'FastAPI<br/>service'),(1352,'XGBoost<br/>model')]:
    rect(x,1910,216,107,LIGHT,P)
    para(label,x+6,1926,204,27,35,D,True,1)
    if x<1352:
        c.setStrokeColor(P);c.setLineWidth(3)
        yy=H-1963;c.line(x+218,yy,x+249,yy)
        c.line(x+249,yy,x+241,yy+8);c.line(x+249,yy,x+241,yy-8)
para('Vehicle details and estimated price in PKR',838,2041,730,27,36,BODY,False,1)
rect(1090,2130,304,94,LIGHT,P)
para('Firebase<br/>Accounts and records',1096,2141,292,25,33,D,False,1)
c.setStrokeColor(P);c.setLineWidth(2.5)
c.line(946,H-2017,946,H-2177);c.line(946,H-2177,1090,H-2177)

heading('RESULTS',2375)
para('9,849',169,2470,960,91,105,P,True)
para('vehicle records prepared for model development',169,2590,966,33,44)
y=2701
for t in ['Price estimation on Android and web.','Saved valuations and a garage for multiple cars.','Service history and reminders based on dates and user-updated mileage.']:
    y+=bullet(t,169,y,970,35)+29
para('Estimates reflect advertised prices and do not replace a vehicle inspection.',169,3073,970,27,37,maxh=80)

welcome=Path(r'C:/Users/PMLS/AppData/Local/Temp/codex-clipboard-c4edcd77-8a98-4f26-97e3-53825e55cfce.png')
predict=Path(r'C:/Users/PMLS/AppData/Local/Temp/codex-clipboard-4575a7ef-342b-4769-8a88-34c0b4c0850f.jpg')
for x,file,crop,label in [(1207,welcome,(54,10,363,703),'Welcome screen'),(1447,predict,None,'Price prediction')]:
    rect(x,2466,204,480,HexColor('#16121F'),HexColor('#16121F'),r=24)
    image_crop(file,x+8,2478,188,456,crop,rounding=15)
    para(label,x-5,2973,214,26,35,D,False,1)

heading('TECHNOLOGIES USED',3221,x=295,w=490,size=32)
for x,top,t in [(363,3300,'Flutter'),(597,3300,'Python'),(363,3392,'XGBoost'),(597,3392,'Firebase'),(363,3484,'FastAPI'),(597,3484,'Docker')]:
    para(t,x,top,215,32,43,D,True,1)
heading('SUMMARY',3210,x=839,w=795,size=32)
para('AutoMetric AI gives buyers and sellers a data-based starting point for price discussions, while helping owners keep vehicle care organized.',839,3263,795,32,43,maxh=135)
rect(1170,3407,174,137,white,P,r=10)
para('Demo QR',1178,3454,158,26,36,BODY,False,1)
heading('PROJECT DEMO',3564,x=1050,w=413,size=32)

# Preserve the four portrait positions using the template's generic placeholders.
placeholder=ROOT/'tmp'/'poster_expo'/'template_assets'/'2_X17.jpg'
centres=[242,660,1033,1405]
for cx in centres:
    cy=H-3840;r=156
    c.saveState(); path=c.beginPath();path.circle(cx,cy,r);c.clipPath(path,stroke=0)
    c.drawImage(str(placeholder),cx-r,cy-r,2*r,2*r,mask='auto')
    c.restoreState(); c.setStrokeColor(HexColor('#D8C9FF'));c.setLineWidth(5);c.circle(cx,cy,r,fill=0,stroke=1)
for cx,role,name,roll in [(242,'Supervisor','Dr. Din Muhammad<br/>Sangrasi',''),(660,'Leader','Abdul Kabeer','22SW067'),(1033,'Member','Mubashir Hussain','22SW061'),(1405,'Member','Azhar Hussain','22SW110')]:
    para(role,cx-180,3628,360,29,38,white,True,1)
    para(name,cx-180,4035,360,29,38,white,True,1)
    if roll:
        para(roll,cx-180,4077,360,27,35,white,True,1)
        rect(cx-62,4132,124,115,white,white,r=12)
        para('LinkedIn<br/>QR',cx-56,4154,112,23,30,BODY,False,1)

c.showPage();c.save();buf.seek(0)
overlay=PdfReader(buf).pages[0]
page.merge_transformed_page(overlay,Transformation().translate(0,float(page.mediabox.bottom)))
# Drop unused images and obsolete project resources from the exported page.
page['/Resources']['/XObject'].update({})
used={str(a[0]) for a,o in ContentStream(page.get_contents(),writer).operations if o==b'Do'}
for key in list(page['/Resources']['/XObject']):
    if str(key) not in used: del page['/Resources']['/XObject'][key]
writer.add_metadata({'/Title':'AutoMetric AI Updated FYP Poster Template','/Author':'AutoMetric AI Project Team','/Subject':'Car valuation and maintenance in Pakistan'})
with OUT.open('wb') as f:writer.write(f)
check=PdfReader(OUT); text=check.pages[0].extract_text()
assert 'VoiceNoteX' not in text and 'Taneesha' not in text
assert 'AutoMetric AI' in text and 'Mubashir Hussain' in text
print(OUT)
print('Original template geometry retained. One page. Selectable replacement text.')

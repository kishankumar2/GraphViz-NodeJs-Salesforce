const express = require("express")
const fs = require('fs');
const { graphviz } = require('node-graphviz');
const app = express()
const { log } = require("console");
const PDFDocument = require("pdfkit")
const SVGtoPDF = require("svg-to-pdfkit")
var util = require('util'),
  gr = require('graphviz');
app.set('port', process.env.PORT || 5000);
//app.use(express.static("public"))
app.use(express.urlencoded({ extended: true }))
app.use(express.json())


app.set("view engine", "ejs")
app.enable('trust proxy');


app.post('/', function(req, res) {
    console.log('Inside the get method');
    console.log(req.body);
    //res.send('Payload received');
   
   
const myMap =  new Map(Object.entries(req.body.data));;
var graph = gr.digraph("G");
//add nodes and edges to the graph from MyMap
for (const [key, value] of myMap.entries()) {
  graph.addNode(key);
    for (const v of value) {
      graph.addNode(v);
      graph.addEdge(key, v);
    }
}
// Print the dot script
console.log( graph.to_dot() );
// Compile the graph to SVG using the `circo` layout algorithm
graphviz.dot(graph.to_dot(), 'svg').then((svg) => {
  // Write the SVG to file
  fs.writeFileSync('assets/graph.svg', svg);

  const doc = new PDFDocument({
    layout: "landscape",
    size: "A0"
  })
  
  const background = fs
  .readFileSync("assets/graph.svg")
  .toString()
  
  SVGtoPDF(doc, background)
  const writeStream = fs.createWriteStream("assets/graph.pdf")
  doc.pipe(writeStream)

  writeStream.on('finish', function () {
    var dataa =fs.readFileSync("assets/graph.pdf",'base64');
  console.log('dataa'+dataa); 
  
  res.send(dataa);
})

  doc.end()

  
});


});


app.listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});

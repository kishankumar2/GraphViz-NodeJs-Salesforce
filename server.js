// Import required modules
const express = require("express")
const fs = require('fs');
const { graphviz } = require('node-graphviz');
const app = express()
const { log } = require("console");
const PDFDocument = require("pdfkit")
const SVGtoPDF = require("svg-to-pdfkit")
var util = require('util'),
  gr = require('graphviz');

// Set the port for the server to listen on
app.set('port', process.env.PORT || 5000);

// Set the view engine to EJS
app.set("view engine", "ejs")

// Enable trust proxy
app.enable('trust proxy');

// Parse incoming requests with urlencoded payloads
app.use(express.urlencoded({ extended: true }))

// Parse incoming requests with JSON payloads
app.use(express.json())

// Handle POST requests to the root URL
app.post('/', function(req, res) {
  console.log('Inside the get method');
  console.log(req.body);

  // Convert the data from the request body to a Map
  const myMap =  new Map(Object.entries(req.body.data));;

  // Create a new graph
  var graph = gr.digraph("G");

  // Add nodes and edges to the graph from myMap
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

    // Create a new PDF document
    const doc = new PDFDocument({
      layout: "landscape",
      size: "A0"
    })

    // Read the SVG file and convert it to a PDF
    const background = fs
    .readFileSync("assets/graph.svg")
    .toString()
    SVGtoPDF(doc, background)

    // Write the PDF to file
    const writeStream = fs.createWriteStream("assets/graph.pdf")
    doc.pipe(writeStream)

    // Send the PDF as a response to the client
    writeStream.on('finish', function () {
      var dataa =fs.readFileSync("assets/graph.pdf",'base64');
      console.log('dataa'+dataa); 
      res.send(dataa);
    })

    doc.end()
  });
});

// Start the server
app.listen(app.get('port'), function () {
  console.log('Express server listening on port ' + app.get('port'));
});

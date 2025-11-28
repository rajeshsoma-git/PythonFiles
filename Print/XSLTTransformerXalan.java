import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import java.io.*;

public class XSLTTransformerXalan {
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: java XSLTTransformerXalan <xsl-file> <xml-file> <output-file>");
            System.exit(1);
        }
        
        try {
            // Set system properties to increase limits for complex XSL files
            System.setProperty("jdk.xml.xpathExprOpLimit", "0"); // Disable XPath expression limit
            System.setProperty("jdk.xml.xpathExprGrpLimit", "0"); // Disable XPath expression group limit
            System.setProperty("jdk.xml.xpathTotalOpLimit", "0"); // Disable total XPath operation limit
            
            // Try to use Xalan explicitly if available, otherwise use default
            TransformerFactory factory;
            try {
                // Try to load Xalan specifically
                factory = TransformerFactory.newInstance("org.apache.xalan.processor.TransformerFactoryImpl", null);
                System.out.println("Using Xalan transformer");
            } catch (Exception e) {
                // Fall back to default transformer with increased limits
                factory = TransformerFactory.newInstance();
                System.out.println("Using default transformer: " + factory.getClass().getName());
            }
            
            // Set additional features to handle large stylesheets
            try {
                factory.setFeature("http://javax.xml.XMLConstants/feature/secure-processing", false);
            } catch (TransformerConfigurationException e) {
                System.out.println("Could not disable secure processing, continuing...");
            }
            
            Source xslSource = new StreamSource(new File(args[0]));
            Transformer transformer = factory.newTransformer(xslSource);
            
            Source xmlSource = new StreamSource(new File(args[1]));
            Result output = new StreamResult(new File(args[2]));
            
            transformer.transform(xmlSource, output);
            System.out.println("Transformation completed successfully!");
        } catch (Exception e) {
            System.err.println("Transformation failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
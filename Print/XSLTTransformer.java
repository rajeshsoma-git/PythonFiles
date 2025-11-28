import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import java.io.*;

public class XSLTTransformer {
    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: java XSLTTransformer <xsl-file> <xml-file> <output-file>");
            System.exit(1);
        }
        
        try {
            TransformerFactory factory = TransformerFactory.newInstance();
            Source xslSource = new StreamSource(new File(args[0]));
            Transformer transformer = factory.newTransformer(xslSource);
            
            Source xmlSource = new StreamSource(new File(args[1]));
            Result output = new StreamResult(new File(args[2]));
            
            transformer.transform(xmlSource, output);
            System.out.println("Transformation completed successfully using: " + factory.getClass().getName());
        } catch (Exception e) {
            System.err.println("Transformation failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

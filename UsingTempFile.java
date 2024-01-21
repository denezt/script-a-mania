import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.stream.Stream;

public class UsingTempFile
{
 public static void main(String[] args) 
 {
  try 
  {
   Path file = Files.createTempFile("testOne", ".txt");

   //Write strings to file indented to 8 leading spaces
   Files.writeString(file, "ABC".indent(8), StandardOpenOption.APPEND);
   Files.writeString(file, "123".indent(8), StandardOpenOption.APPEND);
   Files.writeString(file, "XYZ".indent(8), StandardOpenOption.APPEND); 

   //Verify the content
   Stream<String> lines = Files.lines(file);

   lines.forEach(System.out::println);
  } 
  catch (IOException e) 
  {
   e.printStackTrace();
  }
 }
}

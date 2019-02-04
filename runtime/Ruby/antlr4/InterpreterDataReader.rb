



















# A class to read plain text interpreter data produced by ANTLR.
class InterpreterDataReader 
	
	public static class InterpreterData 
	  ATN atn
	  Vocabulary vocabulary
	  List<String> ruleNames
	  List<String> channels # Only valid for lexer grammars.
	  List<String> modes # ditto
	end
	























	public static InterpreterData parseFile(String fileName) 
		InterpreterData result = new InterpreterData()
		result.ruleNames = new ArrayList<String>()
		
		try (BufferedReader br = new BufferedReader(new FileReader(fileName))) 
		    String line
		  	List<String> literalNames = new ArrayList<String>()
		  	List<String> symbolicNames = new ArrayList<String>()
		
			line = br.readLine()
			if ( !line.equals("token literal names:") )
				throw new RuntimeException("Unexpected data entry")
		    while ((line = br.readLine()) != null) 
		       if ( line.isEmpty() )
					break
				literalNames.add(line.equals("null") ? "" : line)
		    end
		
			line = br.readLine()
			if ( !line.equals("token symbolic names:") )
				throw new RuntimeException("Unexpected data entry")
		    while ((line = br.readLine()) != null) 
		       if ( line.isEmpty() )
					break
				symbolicNames.add(line.equals("null") ? "" : line)
		    end

		  	result.vocabulary = new VocabularyImpl(literalNames.toArray(new String[0]), symbolicNames.toArray(new String[0]))

			line = br.readLine()
			if ( !line.equals("rule names:") )
				throw new RuntimeException("Unexpected data entry")
		    while ((line = br.readLine()) != null) 
		       if ( line.isEmpty() )
					break
				result.ruleNames.add(line)
		    end
		    
			if ( line.equals("channel names:") )  # Additional lexer data.
				result.channels = new ArrayList<String>()
			    while ((line = br.readLine()) != null) 
			       if ( line.isEmpty() )
						break
					result.channels.add(line)
			    end

				line = br.readLine()
				if ( !line.equals("mode names:") )
					throw new RuntimeException("Unexpected data entry")
				result.modes = new ArrayList<String>()
			    while ((line = br.readLine()) != null) 
			       if ( line.isEmpty() )
						break
					result.modes.add(line)
			    end
			end

		  	line = br.readLine()
		  	if ( !line.equals("atn:") )
		  		throw new RuntimeException("Unexpected data entry")
			line = br.readLine()
			String[] elements = line.split(",")
	  		char[] serializedATN = new char[elements.length]

			for (int i = 0 i < elements.length ++i) 
				int value
				String element = elements[i]
				if ( element.startsWith("[") )
					value = Integer.parseInt(element.substring(1).trim())
				else if ( element.endsWith("]") )
					value = Integer.parseInt(element.substring(0, element.length() - 1).trim())
				else
					value = Integer.parseInt(element.trim())
				serializedATN[i] = (char)value					
			end

		  	ATNDeserializer deserializer = new ATNDeserializer()
		  	result.atn = deserializer.deserialize(serializedATN)
		end
		catch (java.io.IOException e) 
			# We just swallow the error and return empty objects instead.
		end
		
		return result
	end
	
end

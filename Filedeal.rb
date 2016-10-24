class Vocabulary
  attr_reader :name
  attr_reader :count
  def initialize value1,value2
    @name=value1
    @count=value2
  end
  def name=(value)
    @name=value
  end
  def count=(value)
    @count=value
  end
end
class Message
  def Step1
      File.open("../带标签短信.txt",'r') do |file|
        @a=String.new
        @b=String.new
        while line=file.gets
          if line[0]=='1'
            @a+=line.to_s
            puts line
          end
          if line[0]=='0'
            @b+=line.to_s
            puts line
          end
        end
        afile=File.new("../垃圾短信.txt",'w')
        afile.syswrite(@a)
        afile.close
        bfile=File.new("../正常短信.txt",'w')
        bfile.syswrite(@b)
        bfile.close
      end
  end
  #还原处理
  #去除非法字符，将短信内容转化为普通的文档格式
  def Step2
     File.open("../垃圾短信.txt",'r') do |file|
       a=String.new
       while line=file.gets
          line.force_encoding("UTF-8")
          line=line.gsub(/\p{P}/,'')
          line=line.gsub(/^[a-zA-Z]+$/,'')
          line=line.gsub(/^[0-9]/,'')
          line=line.gsub(/\u0020/,'')
          a+=line
       end
       newFile=File.new("../还原文件.txt",'w')
       newFile.syswrite(a)
       newFile.close
     end
  end
  #停用词删除
  #去除不必要的停用词
  def Step3
    @p=Array.new
    count=0
    File.open("../停用词.txt",'r') do |file|
        while line=file.gets
          @p[count]=line.force_encoding("UTF-8")
          count+=1
        end
    end
    File.open("../还原文件.txt",'r') do |file|
        a=String.new
        while line=file.gets
          line=line.force_encoding("UTF-8")
          @p.each do |i|
              i=i.chomp
              line=line.delete i
          end
          a+=line
          puts line
        end
        newFile=File.new("../最终文件.txt",'w')
        newFile.syswrite(a)
        newFile.close
    end
  end
  def Step4
    @array=Array.new
    count=0
    File.open("../分词文件1.txt",'r') do |file|
      while line=file.gets
        str=line.force_encoding("UTF-8").split(" ")
        for i in 0..str.length-1
            if (j=position(@array,str[i]))==@array.length
                 vol=Vocabulary.new(str[i],1)
                 @array[j]=vol
            else
                 @array[j].count+=1
            end
        end
      end
    end
    @array=@array.sort{|a,b| a.count<=>b.count}
    @array=@array.reverse
    newFile=File.new("../分频文件.txt",'w')
    @array.each do |i|
      newFile.syswrite(i.name.to_s+":"+i.count.to_s+"\n")
    end
    newFile.close
  end
  def position(array,value)
    count=0
    array.each do |i|
      if i.name==value
        return count
      end
      count+=1
    end
    return count
  end
end
class Main
  p=Message.new
  p.Step4
end

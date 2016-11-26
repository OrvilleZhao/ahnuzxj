class Array
  #矩阵转置
  def T
    m=self.size
    n=0
    if m>0
      n=self[0].size
    end
    if m<1||n<1
      raise ArgumentError
    end
    a=Array.new(n){Array.new(m)}
    for i in 0..n-1
      for j in 0..m-1
        a[i][j]=self[j][i]
      end
    end
    return a
  end
  #矩阵乘法
  def multiply a
    m=self.size
    n=0
    if m>0
      n=self[0].size
    end
    if a.length!=n
      raise ArgumentError
    end
    if a[0].length<1
      raise ArgumentError
    end
    h=a[0].length
    newMatrix=Array.new(m){Array.new(h)}
    for i in 0..m-1
      for j in 0..h-1
        count=0
        for s in 0..n-1
          count+=self[i][s]*a[s][j]
        end
        newMatrix[i][j]=count
      end
    end
    if m==1&&h==1
      return newMatrix[0][0].to_f
    else
      return newMatrix
    end
  end
  #返回指定的行列或元素
  def select(i,j)
    @m=self.size
    @n=0
    if @m>0
      @n=self[0].size
    end
    if i==':'&&j==':'
      return self
    elsif i==':'&&j>=0&&j<@n
      array=Array.new(@m){Array.new(1)}
      for s in 0..@m-1
        array[s][0]=self[s][j]
      end
      return array
    elsif j==':'&&i>=0&&i<@m
      array=Array.new(1){Array.new(@n)}
      for s in 0..@n-1
        array[0][s]=self[i][s]
      end
      return array
    elsif i>=0&&i<@m&&j>=0&&j<@n
      return self[i][j]
    else
      raise ArgumentError
    end
  end
  #向量相乘
  def vectormultiply a
    if self.length==a.length&&a.length>0
      if self[0].length==a[0].length&&a[0].length>0
        l=Array.new(self.length){Array.new(self[0].length)}
        for i in 0..self.length-1
          for j in 0..self[0].length-1
            l[i][j]=self[i][j]*a[i][j]
          end
        end
        return l
      end
    end
    raise ArgumentError
  end
  #生成0矩阵
  def zeros(i,j)
    array=Array.new(i){Array.new(j,0)}
    return array
  end
  #生成非0矩阵
  def nonzero
    nonzeroCount=0
    array1=Array.new
    array2=Array.new
    if self.length>0&&self[0].length>0
      for i in 0..self.length-1
        for j in 0..self[0].length-1
          if self[i][j]>0
            nonzeroCount+=1
            array1.insert(i)
            array2.insert(j)
          end
        end
      end
      a=Array.new(2){Array.new(nonzeroCount)}
      a[0]=array1
      a[1]=array2
      return a
    end
  end
  #改变某一行的值
  def set(i,j)
    if self[i].length==j.length
      self[i]=j
    end
  end
end
class Recog
  def fileload
    @b=1.5442725785489309
    @alpha=Array.new
    @dataMatIn=Array.new
    @classLabels=Array.new
    @recogMat=Array.new
    @textLabels=Array.new
    File.open("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/Answer.txt",'r') do |file|
      while line=file.gets
        @alpha.insert(@alpha.length,[line.split(':')[1].to_f])
      end
    end
    a=Array.new
    File.open("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/tfidf文件.txt",'r') do |file|
      count=0
      while line=file.gets
        count+=1
        line.force_encoding("UTF-8")
        lineArr=line.split(' ')
        a.insert(a.length,lineArr[0])
        if count==200
          break
        end
      end
    end
    File.open("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/带标签短信.txt",'r') do |file|
      count=0
      while line=file.gets
        count+=1
        line.force_encoding("UTF-8")
        lineArr=line.split(' ')
        if count<=200
            if lineArr[0]=='0'
              @classLabels.insert(@classLabels.length,[1])
            else
              @classLabels.insert(@classLabels.length,[-1])
            end
            charNum=Array.new
            for i in 0..a.length-1
              charNum.insert(charNum.length,scount(lineArr[1],a[i]))
            end
            @dataMatIn.insert(@dataMatIn.length,charNum)
        else
            charNum=Array.new
            if lineArr[0]=='0'
              @textLabels.insert(@textLabels.length,1)
            else
              @textLabels.insert(@textLabels.length,-1)
            end
             for i in 0..a.length-1
               charNum.insert(charNum.length,scount(lineArr[1],a[i]))
             end
             @recogMat.insert(@recogMat.length,charNum)
        end
      end
    end
  end
  def scount str,str1
    arr=str.split(str1)
    return arr.length-1
  end
  def recognition
    preCorrectCount=0.0#正确预测的正样本数
    prePositiveCount=0.0#预测为正例的样本数
    positiveCount=0.0#标注的正样本数
    for i in 0..@recogMat.length-1
      k=@alpha.vectormultiply(@classLabels).T.multiply(@dataMatIn.multiply(@recogMat.select(i,':').T)).to_f+@b
      if (k>0&&@textLabels[i]==1)
        preCorrectCount+=1.0
      end
      if @textLabels[i]==1
        positiveCount+=1.0
      end
      if k>0
        prePositiveCount+=1.0
      end
    end
    precision=(preCorrectCount/prePositiveCount).to_f
    recall=(preCorrectCount/positiveCount).to_f
    puts "Precision:"+precision.to_s
    puts "Recall:"+recall.to_s
    puts "F1:"+(2.0*(precision*recall)/(precision+recall)).to_s
  end
end
class Test
  a=Recog.new
  a.fileload
  a.recognition
end

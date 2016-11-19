class Naive
  def fileLoad
    @classLabels=Array.new
    @dataMatIn=Array.new
    @recogMat=Array.new
    @positiveE=0
    @negativeE=0
    @textLabels=Array.new
    #初始化特征数组
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
    @Max=Array.new(a.length){|index| 0}
    File.open("C:/Users/Administrator/Desktop/讲义/网络数据挖掘大作业/带标签短信.txt",'r') do |file|
      count=0
      while line=file.gets
        count+=1
        line.force_encoding("UTF-8")
        lineArr=line.split(' ')
        if count<=200
            if lineArr[0]=='0'
              @classLabels.insert(@classLabels.length,1)
              @positiveE+=1
            else
              @classLabels.insert(@classLabels.length,-1)
              @negativeE+=1
            end
            charNum=Array.new
            for i in 0..a.length-1
              sum=scount(lineArr[1],a[i])
               if sum.to_i>@Max[i].to_i
                 @Max[i]=sum
               end
              charNum.insert(charNum.length,sum)
            end
            @dataMatIn.insert(@dataMatIn.length,charNum)
        else
          if lineArr[0]=='0'
            @textLabels.insert(@textLabels.length,1)
          else
            @textLabels.insert(@textLabels.length,-1)
          end
          charNum=Array.new
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
  def init
      @x=Array.new(200){Array.new(2)}
      #计算在正负例情况下的概率----采用贝叶斯估计
      @pYp=((@positiveE.to_f+1.0)/(@dataMatIn.length.to_f+2.0)).round(8)
      @pYg=((@negativeE.to_f+1.0)/(@dataMatIn.length.to_f+2.0)).round(8)
      for i in 0..@x.length-1
          pCount=Array.new(@Max[i]+1){|index| 0}
          nCount=Array.new(@Max[i]+1){|index| 0}
          for j in 0..@dataMatIn.length-1
             if @classLabels[j]==1
                pCount[@dataMatIn[j][i]]+=1
             end
             if @classLabels[j]==-1
                nCount[@dataMatIn[j][i]]+=1
             end
          end
          for k in 0..@Max[i]
            pCount[i]=((pCount[i].to_f+1.0)/(@positiveE+@Max[i])).round(8)
            nCount[i]=((nCount[i].to_f+1.0)/(@negativeE+@Max[i])).round(8)
          end
          @x[i][0]=pCount
          @x[i][1]=nCount
      end
  end
  def search
    count=0
    for i in 0..@recogMat.length-1
      pProbability=1.0
      nProbability=1.0
      for j in 0..199
            a=@recogMat[i][j].to_i
            pProbability=pProbability*@x[j][0][a].to_f
            nProbability=nProbability*@x[j][1][a].to_f
      end
      pAnswer=@pYp*pProbability
      nAnswer=@pYg*nProbability
      if (pAnswer>nAnswer&&@textLabels[i]==1)||(pAnswer<nAnswer&&@textLabels[i]==-1)
          count+=1
      end
    end
    puts "正确率为:"+((count.to_f/@recogMat.length.to_f)*100).to_s+"%"
  end
end
class Test
   k=Naive.new
   k.fileLoad
   puts "文件处理完毕"
   k.init
   puts "概率计算完毕"
   k.search
end

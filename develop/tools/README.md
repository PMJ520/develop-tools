## jar（1.0）说明 
#### 本jar（1.0）仅有2个类，分别针对于json转换和获取Bean的有效参数组合
##### kim.pmj.develop.utils.HyGsonUtils #json转换，注意：仅将bean转换为json字符串<br>
>google的Gson和alibaba的fastjson均可以在bean和字符串之间转换，但是效率少则20毫秒，高则100毫秒，效率损耗太大，因此我对于需要将bean转为字符串的需求，我都是在bean中创建一个方法，采用字段拼接的方式转换字符串，效率非常高，几乎用不了1毫秒。但是在创建这个方法的时候，手动创建也很烦琐并且容易犯错，因此此>>类中的beansFileToJsonBasicType方法即可快捷创建这个方法。ps：生成后的需要手动复制到bean中哈<br>
##### kim.pmj.develop.utils.HyVaildValuesUtils #有效参数 
>在一些场景中，我们需要获取某个bean的有效参数，例如非null、非0等非默认值的参数；我们可以创建一个方法，对参数进行判断然后拼接为自己想要的字符串。<br>
但是在创建这个方法的时候，手动创建也很烦琐并且容易犯错，因此此类中的beansFileToJsonBasicType方法即可快捷创建这个方法。ps：生成后的需要手动复制到bean中哈

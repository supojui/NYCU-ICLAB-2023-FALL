## 簡介
跟lab09的題目一樣，只是這次是要寫pattern，跟checker，pattern主要是用來看能不能檢查到所有的spec violation，checker則是用來確認生出來的測資的coverage有沒有符合標準。

## 優化Tips
這次的performance是用coverage的simulation time去比，也就是說理論上測資越少筆performance會越好，我想大部分的人都是直接算能滿足所有spec的最小pattern數，如果題目沒改的話應該是3600筆。system verilog裡pattern、checker的寫法又跟design很不一樣，我覺得直接看別人的寫法會比看講義慢慢學還快很多，這次lab應該不算難，不用太緊張。

如果有人在寫chcker的時候一直遇到某個spec tool跑出來的結果跟預期的差很多，可以去看一下觸發的條件是不是有需要加上iff，如果沒有的話可以參考下面的寫法加上iff試試看。
``` system verilog
covergroup Spec2 @(posedge clk iff inf.size_valid);
    option.per_instance = 1;
    option.at_least = 100;
    coverpoint bev_info.bev_size{
        bins b_bev_size [] = {[L:S]};
    }
endgroup
```

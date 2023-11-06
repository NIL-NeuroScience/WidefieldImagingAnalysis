function plot_allen_outlines(regions_table,AllenOutline,color)
% Version 1.0 Harrison Fisher 12/19/2021
%plot_allen_outlines Plot the outlines of all the regions and edges 
%  
hold on
plot(AllenOutline(:,1),AllenOutline(:,2),color,'LineWidth',2)
for r = 1:height(regions_table)
    plot(regions_table.left_x{r},regions_table.left_y{r},color,'LineStyle','-','LineWidth',1.5)
    plot(regions_table.right_x{r},regions_table.right_y{r},color,'LineStyle','-','LineWidth',1.5)
end
end


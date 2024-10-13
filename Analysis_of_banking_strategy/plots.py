import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

def hist_plot(feature, size = (4,4), color = "gray", bins = 30, ):

    ageMean = feature.mean()                                    # mean age
    ageMode = feature.mode()[0]                                 # mode age
    ageMedian = feature.median()                                # median age

    plt.figure(figsize=size)
    sns.histplot(feature, kde=False, color = color, bins= bins)
    
    plt.axvline(ageMean, color='red', linestyle='--', label=f'Mean: {ageMean:.2f}')
    plt.axvline(ageMedian, color='yellow', linestyle='--', label=f'Median: {ageMedian:.2f}')
    plt.axvline(ageMode, color='green', linestyle='--', label=f'Mode: {ageMode:.2f}')
    plt.legend()

def plot_bar_pct(col, xlabel, ylabel, title, color = "turquoise", size = (8,4)):

    count = col.value_counts()                                       # number of instances
    
    pct_count = count * 100/count.sum()                              # pct of each category
    
    df_count = pd.DataFrame({'count':count, 'percentage': pct_count})

    plt.figure(figsize=size)
    bars = plt.bar(df_count.index, df_count['count'], color= color)  # bar plot
    
    for bar, pct in zip(bars, df_count['percentage']):
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2.0, height,             # position of pct text
            f'{pct:.2f}%', 
            ha='center', va='bottom'
        )
    plt.xlabel(f"{xlabel}")
    plt.ylabel(f"{ylabel}")
    plt.title(f"{title}")
    plt.show()

def pie_plot(feature, title, color = "muted", size = (4,4), ang = 135):
    count = feature.value_counts()
    
    plt.figure(figsize=size)
    plt.pie(count, labels=count.index, autopct='%1.1f%%', startangle=ang, colors=sns.color_palette(color))
    plt.title(title)
    plt.show()
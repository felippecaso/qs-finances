def model(dbt, session):

    import re
    from textblob.classifiers import NaiveBayesClassifier
    
    import nltk
    import pandas as pd


    try:
        nltk.data.find('tokenizers/punkt')
    except LookupError:
        nltk.download('punkt')

    def _strip_numbers(s):
        """Strip numbers from the given string"""
        return re.sub("[^A-Z ]", "", str(s))

    def _split_by_multiple_delims(string, delims):
        """Split the given string by the list of delimiters given"""
        regexp = "|".join(delims)
        return re.split(regexp, string)

    def _get_training(df):
        """Get training data for the classifier, consisting of tuples of
        (text, category)"""
        train = []
        subset = df.loc[(df['category']!='') & (df['category_source']!='guess')].reset_index(drop=True)
        for i in subset.index:
            row = subset.iloc[i]
            new_desc = _strip_numbers(row['description'])
            train.append( (new_desc, row['category']) )
        return train

    def _extractor(doc):
        """Extract tokens from a given string"""
        tokens = _split_by_multiple_delims(doc, [' ', '/'])
        features = {}
        for token in tokens:
            if token == "":
                continue
            features[token] = True
        return features

    int_transactions_unioned = dbt.ref('int_transactions_unioned').df()
    transactions_categorized = dbt.source('finances', 'transactions_categorized').df()

    category_columns = ['transaction_id', 'category', 'category_source']
    merged_df = int_transactions_unioned.merge(transactions_categorized[category_columns], on='transaction_id', how='left', suffixes=('_left', '_right'))

    train_df = merged_df[(merged_df['category'].notnull()) & (merged_df['category_source'] != 'guess')].reset_index(drop=True)
    classify_df = merged_df[(merged_df['category'].isnull()) | (merged_df['category_source'] == 'guess')].reset_index(drop=True)

    classifier = NaiveBayesClassifier(_get_training(train_df), _extractor)
    classify_df['category'] = classify_df['description'].apply(lambda x: classifier.classify(_strip_numbers(x)))
    classify_df['category_source'] = 'guess'

    finances_categories = dbt.source('finances', 'categories').df()
    final_df = pd.concat([classify_df, train_df]).reset_index(drop=True).merge(finances_categories, on='category', how='left')

    return final_df
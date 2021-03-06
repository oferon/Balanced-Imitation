% calculate clusters diversity
% find all clusters and p(cluster)
% find mean pitch, FM, entropy, duration for each cluster
% normalize them according to SAP scale 
% for each pair of clusters: find accoustic distance, and multiply by pi pj
% usage: first export table from mySQL WorkBench
% usage: [results, diversity]=clusterDiversity(table_name);
% clusterDiversity=name of function; name of file must be same as name of
% function
function [bigrams, bigramDiv, bigramDivOffDiag, results, Cluster_Diversity, Cluster_Diversity2, Cluster_Diversity3,Cluster_Diversity4] = clusterDiversity(table)
    cluster=table.cluster;
    dur=table.duration;
    pitch=table.mean_pitch;
    FM=table.mean_FM;
    entropy=table.mean_entropy;
    Ucluster=unique(cluster);
    Ucluster=Ucluster(Ucluster>0);
    numclust=length(Ucluster);
    results=zeros(numclust,9);
    for i=1:numclust
        % compute number of syll in cluster
        results(i,1)=length(cluster(cluster==Ucluster(i))); 
        % compute raw mean features
        results(i,2)=mean(dur(cluster==Ucluster(i)));
        %variable pitch, searching pitch according to second variable
        %called cluster which has the same duration (the 2 are aligned).
        %Allows you to say give me all pitches for one line, while another
        %vector is equal to a certain value (name of unique
        %clusters). Searching by cluster for pitch, retrieving all pitches
        %were cluster = certain value, then compute mean of all values.
        results(i,3)=mean(pitch(cluster==Ucluster(i)));
        %in MatLab, one = is an assignment. Logical equal uses double ==
        %instead, e.g., IF something == something
        results(i,4)=mean(FM(cluster==Ucluster(i)));
        results(i,5)=mean(entropy(cluster==Ucluster(i)));
        % now compute scaled features, subtract median and divide by MAD
        % not from number, but from entire vector (every number in vector)
        results(i,6)=(results(i,2)-74)/52.4;
        results(i,7)=(results(i,3)-1185)/841;
        results(i,8)=(results(i,4)-41.2)/10.1;
        results(i,9)=(results(i,5)+2.23)/0.79;
    end
    % calculate diversity
    % all syllables in table that fall into a cluster
    sc=sum(results(:,1));
    %proportion of values = number of syllables in each cluster divided by
    %the total number of syllables that fall into clusters
    pvals=results(:,1)./sc;
    Cluster_Diversity=0;
    Cluster_Diversity2=0;
    Cluster_Diversity3=0;
    Cluster_Diversity4=0;
    
    for i=1:numclust
        %exactly the same measure used for vocal states -p(log(p)), sum of
        %all clusters
        Cluster_Diversity4=Cluster_Diversity4-pvals(i)*log2(pvals(i));
        for j=i+1:numclust
           %distance = ((results(pitch1)-results(pitch2))^2 + res(FM)-....
           distance = (results(i,6)-results(j,6))^2 + (results(i,7)-results(j,7))^2 + (results(i,8)-results(j,8))^2 + (results(i,9)-results(j,9))^2;
           %sq root of that distance * Proportion of sounds in C1 (out of total number of sounds in song) * P of
           %sounds in C2...
           Cluster_Diversity=Cluster_Diversity+ (sqrt(distance) * pvals(i) * pvals(j));
           %cluster diversity 2 is same as 1, but cluster_diversity is
           %multiplied by the duration of the shortest syllable. 52.4 ms=
           %mean duration of ZF syllables across birds. 7-800 average song.
           Cluster_Diversity2=Cluster_Diversity2+ sqrt(distance) * pvals(i) * pvals(j) * min(results(i,2) , results(j,2))/52.4;% scale by shoter syllable / MAD dur
          %same as cluster_diversity but no distance
           Cluster_Diversity3=Cluster_Diversity3+(pvals(i) * pvals(j));
 
        end
    end
    
    % now do bigrams
    bigrams=zeros(numclust,numclust);
    for i=1:length(cluster)-1
       if cluster(i)>0 && cluster(i+1)>0
           bigrams(cluster(i),cluster(i+1))= bigrams(cluster(i),cluster(i+1)) +1;
       end
    end
    
    % find bigram diversity
    bigramsScale=bigrams./sum(sum((bigrams))); % these are the proportions for each bigram
    bigramlogs=bigramsScale;
    bigramlogs(bigramlogs>0)=log2(bigramlogs(bigramlogs>0));
    bigramDiv=sum(sum(-bigramsScale.*bigramlogs));
    % find off diagonal diversity
    bigramsScaleOffDiag=bigrams;
    for i=1:8
        bigramsScaleOffDiag(i,i)=0;
    end
    bigramsScale=bigramsScaleOffDiag./sum(sum((bigramsScaleOffDiag)));
    bigramlogs=bigramsScale;
    bigramlogs(bigramlogs>0)=log2(bigramlogs(bigramlogs>0));
    bigramDivOffDiag=sum(sum(-bigramsScale.*bigramlogs));
    %Cluster_Diversity=results;
end
